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
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }

    stages {
        stage('Terraform Plan') {
            when {
                expression {
                    !params.Destroy
                }
            }

            steps {
                dir("terraform") {
                    mkdir '-p plans'
                    sh 'terraform init -no-color -input=false'
                    //sh 'terraform workspace select ${environment} || terraform workspace new ${environment}'

                    sh "terraform plan -no-color -input=false -out plans/${COMMIT_HASH}.tf"
                    //sh "aws s3 cp plans/${COMMIT_HASH} s3://${TF_S3_BUCKET}"
                    sh "terraform show -no-color plans/${COMMIT_HASH}.tf"
                }
            }
        }
        stage('Terraform Apply') {
            when {
                expression {
                    params.Apply && !params.Destroy
                }
            }

            steps {
                dir("terraform") {
                    sh "terraform apply -no-color -input=false plans/${COMMIT_HASH}.tf"
                }
            }
        }

        /*
        stage('Terraform Get Output') {
            when { expression { params.APPLY } }
            steps {
                dir("terraform") {
                    sh 'terraform refresh'
                    sh 'terraform output | tr -d \'\\\"\\ \' > env.tf'
                }
            }
        }
        */

        stage('Terraform Destroy') {
            when {
                expression {
                  params.Destroy
                }
            }

        steps {
            dir("terraform") {
               sh "terraform destroy -no-color -auto-approve plans/plan-${COMMIT_HASH}.tf"
            }
        }
    }

  }
}
