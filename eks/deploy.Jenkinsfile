#!groovy
pipeline {
    agent any

    environment {
        project_name = "AB-utopia"
        env          = "dev"

        cluster_name        = "$project_name"
        s3_bucket           = project_name.toLowerCase()
        docker_image_prefix = project_name.toLowerCase()
    }

    stages {
        stage('Create cluster') {
            steps {
                dir("eks") {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: "jenkins",
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        script {
                            // get terraform output
                            sh "aws s3 cp s3://$s3_bucket/env:/$env/tf_output_backup.json tf_output.json"
                            def tf_output = readJSON file: 'tf_output.json'
                            def aws_account_id = sh(
                                script: 'aws sts get-caller-identity --query "Account" --output text',
                                returnStdout: true
                            ).trim()
                            // create eks cluster
                            def private_subnets = tf_output.nat_private_subnet_ids.toList().join(',')
                            sh """
                                eksctl create cluster \
                                    --name $cluster_name \
                                    --region $region \
                                    --nodes 2 \
                                    --node-type t3.small \
                                    --alb-ingress-access \
                                    --vpc-private-subnets $private_subnets
                            """
                        }
                    }
                }
            }
        }

        stage('Setup AWS load balancer ingress controller') {
            steps {
                dir("eks") {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: "jenkins",
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        script {
                            def tf_output = readJSON file: 'tf_output.json'
                            def aws_account_id = sh(
                                script: 'aws sts get-caller-identity --query "Account" --output text',
                                returnStdout: true
                            ).trim()
                            // Associate IAM OIDC provider for ALB
                            sh "aws eks update-kubeconfig --region $region --name $cluster_name"
                            sh """
                                eksctl utils associate-iam-oidc-provider \
                                    --region "$region" \
                                    --cluster "$cluster_name" \
                                    --approve
                            """

                            // Create IAM service account w/ role & attached policies for ALB
                            sh """
                                eksctl create iamserviceaccount \
                                    --name=aws-load-balancer-controller \
                                    --cluster "$cluster_name" \
                                    --namespace=kube-system \
                                    --attach-policy-arn="arn:aws:iam::$aws_account_id:policy/AWSLoadBalancerControllerIAMPolicy" \
                                    --attach-policy-arn="arn:aws:iam::$aws_account_id:policy/AWSLoadBalancerControllerAdditionalIAMPolicy" \
                                    --override-existing-serviceaccounts \
                                    --approve
                            """

                            // Install the TargetGroupBinding custom resource definitions
                            sh "kubectl apply -k 'github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master'"

                            // Install AWS load balancer controller
                            sh """
                                helm upgrade \
                                    -i aws-load-balancer-controller aws-load-balancer-controller \
                                    --repo https://aws.github.io/eks-charts \
                                    --set clusterName="$cluster_name" \
                                    --set vpcId="${tf_output.vpc_id}" \
                                    --set region="$region" \
                                    --set serviceAccount.create=false \
                                    --set serviceAccount.name=aws-load-balancer-controller \
                                    -n kube-system
                            """
                        }
                    }
                }
            }
        }

        stage('Deploy microservices') {
            steps {
                dir("eks") {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: "jenkins",
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        script {
                            def tf_output = readJSON file: 'tf_output.json'
                            def aws_account_id = sh(
                                script: 'aws sts get-caller-identity --query "Account" --output text',
                                returnStdout: true
                            ).trim()
                            // Make sure microservices namespace is present
                            sh "kubectl apply -f k8s/namespace.yml"
                            // Set k8s secrets from stdin literals
                            withCredentials([
                                string(
                                    credentialsId: "${env.toLowerCase()}/$project_name/default",
                                    variable: 'SECRETS'
                                )
                            ]) {
                                def aws_secrets = readJSON text: SECRETS
                                sh """
                                    kubectl create secret generic db-info \
                                        -n microservices \
                                        --from-literal db-url="mysql://${tf_output.mysql_url}:3306/utopia" \
                                        --from-literal db-user="${aws_secrets.db_username}" \
                                        --from-literal db-password="${aws_secrets.db_password}"
                                    kubectl create secret generic jwt-secret \
                                        -n microservices \
                                        --from-literal jwt-key="${aws_secrets.jwt_secret}"
                                """
                            }

                            // Deploy microservices
                            for(microservice in [
                                "flights-microservice",
                                "bookings-microservice",
                                "users-microservice"
                            ]) {
                                sh """
                                    ECR_PREFIX="$aws_account_id.dkr.ecr.$region.amazonaws.com/$docker_image_prefix" \
                                        envsubst < "k8s/${microservice}.yml" | kubectl apply -f -
                                """
                            }
                            // Apply ingress rules
                            sh """
                                DOMAIN="${tf_output.subdomain}" \
                                AWS_REGION="$region" \
                                AWS_ACCOUNT_ID="$aws_account_id" \
                                ACM_CERT_ARN="${tf_output.acm_cert_arn}" \
                                    envsubst < k8s/ingress.yml | kubectl apply -f -
                            """
                        }
                    }
                }
            }
        }

        stage('Update R53 record w/ external-dns') {
            steps {
                dir("eks") {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: "jenkins",
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        script {
                            def tf_output = readJSON file: 'tf_output.json'
                            def aws_account_id = sh(
                                script: 'aws sts get-caller-identity --query "Account" --output text',
                                returnStdout: true
                            ).trim()
                            // Create IAM service account w/ role & attached policies for external-dns
                            sh """
                                eksctl create iamserviceaccount \
                                    --name=external-dns \
                                    --cluster "$cluster_name" \
                                    --namespace=default \
                                    --attach-policy-arn=arn:aws:iam::$aws_account_id:policy/AllowExternalDNSUpdates \
                                    --override-existing-serviceaccounts \
                                    --approve
                            """

                            // Apply external-dns deployment manifest
                            sh """
                                DOMAIN="${tf_output.subdomain}" \
                                AWS_ACCOUNT_ID="$aws_account_id" \
                                R53_ZONE_ID="${tf_output.r53_zone_id}" \
                                IAM_SERVICE_ROLE_NAME="$cluster_name-external-dns" \
                                    envsubst < k8s/external-dns.yml | kubectl apply -f -
                            """
                        }
                    }
                }
            }
        }
    }
}

