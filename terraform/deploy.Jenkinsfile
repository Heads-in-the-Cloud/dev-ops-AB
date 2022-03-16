#!groovy
pipeline {
    agent any

   environment {
        ENV        = "dev"
        REGION     = "us-west-2"
        PROJECT_ID = "AB-utopia"

        s3_bucket      = PROJECT_ID.toLowerCase()
        num_availability_zones = 2
    }

    stages {
        stage('Init & Plan') {
            steps {
                dir("terraform") {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: "jenkins",
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        script {
                            sh "terraform init -backend-config='bucket=$s3_bucket' -backend-config='region=$REGION'"
                            sh "terraform workspace select $ENV || terraform workspace new $ENV"
                            sh """cat > terraform.tfvars << EOF
region = "$REGION"
name_prefix = "$PROJECT_ID"
environment = "$ENV"
EOF
                        """
                            sh "terraform plan -input=false -out=tfplan"
                        }
                    }
                    sh "terraform show tfplan"
                }
            }
        }

        stage('Apply') {
            steps {
                dir("terraform") {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: "jenkins",
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh "terraform apply -input=false tfplan"
                    }
                }
            }
        }
    }
}
