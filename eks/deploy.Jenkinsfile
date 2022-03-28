#!groovy

pipeline {
    agent any

    environment {
        project_name = "AB-utopia"
        environment  = "dev"
        region       = "us-west-2"
        iam_username = "Austin"
        node_type    = "t3.small"

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
                            aws_account_id = sh(
                                script: 'aws sts get-caller-identity --query "Account" --output text',
                                returnStdout: true
                            ).trim()
                            // get terraform output
                            sh "aws s3 cp s3://$s3_bucket/env:/${environment.toLowerCase()}/tf_info.json ."
                            tf_info = readJSON file: 'tf_info.json'
                            // create eks cluster
                            def private_subnets = tf_info.nat_private_subnet_ids.toList().join(',')
                            sh """
                                eksctl create cluster \
                                    --name ${tf_info.eks_cluster_name} \
                                    --region $region \
                                    --nodes ${tf_info.num_availability_zones} \
                                    --node-type $node_type \
                                    --node-private-networking \
                                    --alb-ingress-access \
                                    --vpc-private-subnets $private_subnets
                            """

                            // Configure IAM user permissions in dev environment
                            if(environment == "dev") {
                                sh """
                                    AWS_ACCOUNT_ID=$aws_account_id \
                                    IAM_USERNAME=$iam_username \
                                        ./aws-auth.sh
                                """
                            }
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
                            // Associate IAM OIDC provider for ALB
                            sh """
                                eksctl utils associate-iam-oidc-provider \
                                    --region "$region" \
                                    --cluster "${tf_info.eks_cluster_name}" \
                                    --approve
                            """

                            // TODO: implement
                            // Cloudwatch logging setup
                            //sh "REGION='$region' envsubst < k8s/cloudwatch.yml | kubectl apply -f -"

                            // Create IAM service account w/ role & attached policies for ALB
                            sh """
                                eksctl create iamserviceaccount \
                                    --name=aws-load-balancer-controller \
                                    --cluster "${tf_info.eks_cluster_name}" \
                                    --namespace=kube-system \
                                    --attach-policy-arn="arn:aws:iam::$aws_account_id:policy/AWSLoadBalancerControllerIAMPolicy" \
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
                                    --set clusterName="${tf_info.eks_cluster_name}" \
                                    --set vpcId="${tf_info.vpc_id}" \
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
                            // Make sure microservices namespace is present
                            sh "kubectl apply -f k8s/namespace.yml"
                            // Set k8s secrets from stdin literals
                            withCredentials([
                                string(
                                    credentialsId: "${environment.toLowerCase()}/$project_name/default",
                                    variable: 'SECRETS'
                                )
                            ]) {
                                def aws_secrets = readJSON text: SECRETS
                                sh """
                                    kubectl create secret generic db-info \
                                        -n microservices \
                                        --from-literal db-url="mysql://${tf_info.mysql_url}" \
                                        --from-literal db-user="${aws_secrets.db_username}" \
                                        --from-literal db-password="${aws_secrets.db_password}"
                                    kubectl create secret generic jwt-key \
                                        -n microservices \
                                        --from-literal value="${aws_secrets.jwt_secret}"
                                """
                            }

                            // Deploy microservices
                            for(microservice in [
                                "flights-microservice",
                                "bookings-microservice",
                                "users-microservice"
                            ]) {
                                sh """
                                    ECR_PREFIX="${aws_account_id}.dkr.ecr.${region}.amazonaws.com/$docker_image_prefix" \
                                        envsubst < "k8s/${microservice}.yml" | kubectl apply -f -
                                """
                            }
                            // Apply ingress rules
                            sh """
                                DOMAIN="${tf_info.subdomain_prefix}.${tf_info.domain}" \
                                AWS_REGION="$region" \
                                AWS_ACCOUNT_ID="$aws_account_id" \
                                ACM_CERT_ARN="${tf_info.acm_cert_arn}" \
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
                            // Create IAM service account w/ role & attached policies for external-dns
                            sh """
                                eksctl create iamserviceaccount \
                                    --name=external-dns \
                                    --cluster "${tf_info.eks_cluster_name}" \
                                    --namespace=default \
                                    --attach-policy-arn=arn:aws:iam::$aws_account_id:policy/AllowExternalDNSUpdates \
                                    --override-existing-serviceaccounts \
                                    --approve
                            """

                            // Apply external-dns deployment manifest
                            sh """
                                DOMAIN="${tf_info.domain}" \
                                AWS_ACCOUNT_ID="$aws_account_id" \
                                R53_ZONE_ID="${tf_info.r53_zone_id}" \
                                IAM_SERVICE_ROLE_NAME="${tf_info.eks_cluster_name}-external-dns" \
                                    envsubst < k8s/external-dns.yml | kubectl apply -f -
                            """
                        }
                    }
                }
            }
        }
    }
}

