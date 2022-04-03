#!groovy

def project_name = 'AB-utopia'

pipeline {
    agent any

    environment {
        // Currently using single-tenancy architecture where build account is dev account
        ENVIRONMENT = 'dev'
        IAM_USERNAME = 'Austin'
        // TODO: test mutli-region deployment
        AWS_REGION = 'us-west-2'

        S3_PATH = "${project_name.toLowerCase()}/env:/$ENVIRONMENT/tf_info.json"
        SECRETS_ID = "$ENVIRONMENT/$project_name/default"
    }

    stages {
        stage('Create cluster') {
            steps {
                dir("eks") {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'jenkins',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        script {
                            // TODO: Multi-tenancy deployment; using different AWS accounts for different environment stages
                            env.AWS_ACCOUNT_ID = sh(
                                script: 'aws sts get-caller-identity --query "Account" --output text',
                                returnStdout: true
                            ).trim()
                            env.ECR_PREFIX = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${project_name.toLowerCase()}"
                            // get terraform output
                            sh 'aws s3 cp s3://$S3_PATH ./tf_info.json'
                            tf_info = readJSON file: 'tf_info.json'
                            // check if eks cluster already exists
                            cluster_exists = sh(
                                script: "eksctl get cluster ${tf_info.eks_cluster_name} --region $AWS_REGION",
                                returnStatus: true
                            ) == 0
                            if(!cluster_exists) {
                                // create cluster if it does not exist
                                def private_subnets = tf_info.nat_private_subnet_ids.toList().join(',')
                                sh """
                                    eksctl create cluster \
                                        --name ${tf_info.eks_cluster_name} \
                                        --region $AWS_REGION \
                                        --fargate \
                                        --alb-ingress-access \
                                        --vpc-private-subnets $private_subnets
                                """

                                // create fargate profile
                                sh """
                                    CLUSTER_NAME=${tf_info.eks_cluster_name} \
                                        envsubst < cluster-config.yml |
                                        eksctl create fargateprofile -f -
                                """

                                // Configure IAM user permissions in dev environment
                                if(environment == "dev") {
                                    sh './aws-auth.sh'
                                }
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
                        credentialsId: 'jenkins',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        script {
                            // Associate IAM OIDC provider for ALB
                            sh """
                                eksctl utils associate-iam-oidc-provider \
                                    --region "$AWS_REGION" \
                                    --cluster "${tf_info.eks_cluster_name}" \
                                    --approve
                            """

                            // TODO: implement
                            // Cloudwatch logging setup
                            //sh "envsubst < k8s/cloudwatch.yml | kubectl apply -f -"

                            if(!cluster_exists) {
                                // Create IAM service account w/ role & attached policies for ALB
                                sh """
                                    eksctl create iamserviceaccount \
                                        --name=aws-load-balancer-controller \
                                        --cluster "${tf_info.eks_cluster_name}" \
                                        --namespace=kube-system \
                                        --attach-policy-arn="arn:aws:iam::$AWS_ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy" \
                                        --override-existing-serviceaccounts \
                                        --approve
                                """
                            }

                            // Install the TargetGroupBinding custom resource definitions
                            sh 'kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"'

                            // Install AWS load balancer controller and wait for it to be ready
                            sh """
                                helm upgrade \
                                    -i aws-load-balancer-controller aws-load-balancer-controller \
                                    --repo https://aws.github.io/eks-charts/ \
                                    --set clusterName="${tf_info.eks_cluster_name}" \
                                    --set vpcId="${tf_info.vpc_id}" \
                                    --set region="$AWS_REGION" \
                                    --set serviceAccount.create=false \
                                    --set serviceAccount.name=aws-load-balancer-controller \
                                    --wait \
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
                        credentialsId: 'jenkins',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        script {
                            if(!cluster_exists) { // TODO: make idempotent implementation to update secrets
                                // Set k8s secrets from stdin literals
                                withCredentials([ string(credentialsId: env.SECRETS_ID, variable: 'SECRETS') ]) {
                                    def aws_secrets = readJSON text: SECRETS
                                    sh """
                                        kubectl create secret generic db-info \
                                            --from-literal db-url="mysql://${tf_info.mysql_url}" \
                                            --from-literal db-user="${aws_secrets.db_username}" \
                                            --from-literal db-password="${aws_secrets.db_password}"
                                    """
                                    sh """
                                        kubectl create secret generic jwt-key \
                                            --from-literal value="${aws_secrets.jwt_secret}"
                                    """
                                }
                            }

                            // Deploy microservices
                            for(name in [ 'flights', 'bookings', 'users' ]) {
                                sh "envsubst < 'k8s/${name}-microservice.yml' | kubectl apply -f -"
                            }
                            // Apply ingress rules
                            sh """
                                DOMAIN="${tf_info.subdomain_prefix}.${tf_info.domain}" \
                                ACM_CERT_ARN="${tf_info.acm_cert_arn}" \
                                    envsubst < k8s/ingress.yml |
                                    kubectl apply -f -
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
                        credentialsId: 'jenkins',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        script {
                            if(!cluster_exists) {
                                // Create IAM service account w/ role & attached policies for external-dns
                                sh """
                                    eksctl create iamserviceaccount \
                                        --name=external-dns \
                                        --cluster "${tf_info.eks_cluster_name}" \
                                        --namespace=default \
                                        --attach-policy-arn=arn:aws:iam::$AWS_ACCOUNT_ID:policy/AllowExternalDNSUpdates \
                                        --override-existing-serviceaccounts \
                                        --approve
                                """
                            }

                            // Apply external-dns deployment manifest
                            sh """
                                DOMAIN="${tf_info.domain}" \
                                R53_ZONE_ID="${tf_info.r53_zone_id}" \
                                IAM_SERVICE_ROLE_NAME="${tf_info.eks_cluster_name}-external-dns" \
                                    envsubst < k8s/external-dns.yml |
                                    kubectl apply -f -
                            """
                            // Wait for external-dns pod to be ready
                            sh '''
                             kubectl wait \
                                --namespace default \
                                --for=condition=ready pod \
                                --selector=app=external-dns \
                                --timeout=180s
                            '''
                        }
                    }
                }
            }
        }
    }
}

