#!groovy
pipeline {
    agent any

    parameters {
        booleanParam(
            name: 'Apply',
            defaultValue: false,
            description: 'Apply Terraform plan?'
        )
        booleanParam(
            name: 'Destroy',
            defaultValue: false,
            description: 'Destroy Terraform build?'
        )
    }

   environment {
        COMMIT_HASH = sh(returnStdout: true, script: "git rev-parse --short=8 HEAD").trim()
        //TF_S3_BUCKET = "tf-plans-ab"
        AWS_REGION = sh(script:'aws configure get region', returnStdout: true).trim()
        PROJECT_ID = credentials('project-id')
        ENV = credentials('env')
        PUB_SSH_KEY = credentials('pub-ssh-key')
    }

    stages {
        stage('Configure Environment Inputs') {
            steps {
                dir("terraform") {
                    sh """
                        cat > terraform.tfvars << EOF
region=${AWS_REGION} \
project_id=${PROJECT_ID} \
environment=${ENV} \
public_ssh_key=${PUB_SSH_KEY}
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
                    sh "terraform show -no-color plans/-apply${COMMIT_HASH}.tf"
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
                    sh """
                        terraform apply -no-color -input=false plans/apply-${COMMIT_HASH}.tf
                    """
                }
            }
        }

        /*
        stage('Terraform Get Output') {
            when {
                expression {
                params.Apply
                }
            }

            steps {
                dir("terraform") {
                    sh 'terraform refresh'
                    sh 'terraform output | tr -d \'\\\"\\ \' > env.tf'
                }
            }
        }
        */

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
                sh 'rm terraform.tfvars'
            }
        }
    }
}
