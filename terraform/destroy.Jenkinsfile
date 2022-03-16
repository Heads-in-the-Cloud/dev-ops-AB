#!groovy
pipeline {
    agent any

    environment {
        project_id  = "AB-utopia"
        region      = "us-west-2"
        s3_bucket   = project_id.toLowerCase()
        environment = "dev"

        subdomain_prefix = project_id.toLowerCase()
        domain           = "hitwc.link"

        vpc_cidr_block   = "10.0.0.0/16"
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
                            sh "terraform init -backend-config='bucket=$s3_bucket' -backend-config='region=$region'"
                            sh "terraform workspace select $environment"
                            sh """cat > terraform.tfvars << EOF
region = "$region"
s3_bucket = "$s3_bucket"
name_prefix = "$project_id"
environment = "$environment"
vpc_cidr_block = "$vpc_cidr_block"
subdomain_prefix = "$subdomain_prefix"
num_availability_zones = "$num_availability_zones"
domain = "$domain"
EOF
                            """
                            sh "terraform plan -destroy -input=false -out=tfplan"
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
