#!groovy
pipeline {
    agent any

    parameters {
        booleanParam(
            name: 'Apply',
            defaultValue: false,
            description: 'Apply Terraform plan and deploy ECS cluster'
        )
        booleanParam(
            name: 'Destroy',
            defaultValue: false,
            description: 'Destroy ECS cluster and Terraform build'
        )
    }

   environment {
        COMMIT_HASH = sh(returnStdout: true, script: "git rev-parse --short=8 HEAD").trim()
        //TF_S3_BUCKET = "tf-plans-ab"
        AWS_REGION = sh(script:'aws configure get region', returnStdout: true).trim()
        AWS_ACCOUNT_ID = sh(script:'aws sts get-caller-identity --query "Account" --output text', returnStdout: true).trim()
        ECR_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

        REVERSE_PROXY_IMAGE = "$ECR_URI/ab-api-gateway:latest"
        FLIGHTS_IMAGE = "$ECR_URI/ab-flights-microservice:latest"
        USERS_IMAGE = "$ECR_URI/ab-users-microservice:latest"
        BOOKINGS_IMAGE = "$ECR_URI/ab-bookings-microservice:latest"

        PROJECT_ID  = credentials('project-id')
        ENV         = credentials('env')
        PUB_SSH_KEY = credentials('pub-ssh-key')
    }

    stages {
        stage('Configure Environment Inputs') {
            steps {
                dir("terraform") {
                    sh """
                        cat > terraform.tfvars << EOF
region = "${AWS_REGION}"
project_id = "${PROJECT_ID}"
environment = "${ENV}"
public_ssh_key = "${PUB_SSH_KEY}"
EOF
                    """
                }
            }
        }

        stage('Terraform Plan Apply') {
            when {
                expression {
                    params.Apply
                }
            }

            steps {
                dir("terraform") {
                    sh 'mkdir -p plans'
                    sh 'terraform init -no-color -input=false'
                    //sh 'terraform workspace select ${environment} || terraform workspace new ${environment}'

                    sh "terraform plan -no-color -input=false -out plans/apply-${COMMIT_HASH}.tf"
                    //sh "aws s3 cp plans/${COMMIT_HASH} s3://${TF_S3_BUCKET}"
                    sh "terraform show -no-color plans/apply-${COMMIT_HASH}.tf"
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression {
                    params.Apply
                }
            }

            steps {
                dir("terraform") {
                    sh "terraform apply -no-color -input=false plans/apply-${COMMIT_HASH}.tf"
                    sh 'terraform refresh -no-color'
                    sh 'terraform output | tr -d \'\\\"\\ \' > ../output.tf'
                }
            }
        }

        stage('ECS cluster') {
            steps {
                script {
                    withCredentials([
                        string(
                            credentialsId: "${ENV}/${PROJECT_ID}/default",
                            variable: 'SECRETS'
                        )
                    ]) {
                        def aws_secrets = readJSON text: SECRETS
                        env.DB_USERNAME = aws_secrets.db_username
                        env.DB_PASSWORD = aws_secrets.db_password
                        env.JWT_SECRET  = aws_secrets.jwt_secret
                    }

                    def tf_outputs = readProperties(file: '../output.tf')
                    env.DOMAIN = tf_output.domain
                    env.VPC_ID = tf_output.vpc_id
                    env.DB_URL = tf_output.db_url
                    env.ALB_ID = tf_output.alb_id

                    dir("ecs-${PROJECT_ID}") {
                        sh "docker context use ecs-${PROJECT_ID}"
                        sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
                        if(params.Apply) {
                            sh "docker compose up --no-color"
                        }
                        if(params.Destroy) {
                            sh "docker compose down --no-color"
                        }
                    }
                }
            }
        }

        stage('Terraform Plan Destroy') {
            when {
                expression {
                    params.Destroy
                }
            }

            steps {
                dir("terraform") {
                    sh 'mkdir -p plans'
                    sh 'terraform init -no-color -input=false'
                    //sh 'terraform workspace select ${environment} || terraform workspace new ${environment}'

                    sh "terraform plan -destroy -no-color -input=false -out plans/destroy-${COMMIT_HASH}.tf"
                    //sh "aws s3 cp plans/${COMMIT_HASH} s3://${TF_S3_BUCKET}"
                    sh "terraform show -no-color plans/destroy-${COMMIT_HASH}.tf"
                }
            }
        }

        stage('Terraform Destroy') {
            when {
                expression {
                    params.Destroy
                }
            }

            steps {
                dir("terraform") {
                    sh "terraform apply -no-color -input=false plans/destroy-${COMMIT_HASH}.tf"
                }
            }
        }
    }

    post {
        cleanup {
            script {
                sh 'rm terraform/terraform.tfvars'
            }
        }
    }
}
