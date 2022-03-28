#!groovy
pipeline {
    agent any

    environment {
        project_name = "AB-utopia"
        environment  = "dev"
        region       = "us-west-2"
        iam_username = "Austin"

        node_type           = "t3.small"
        s3_bucket           = project_name.toLowerCase()
        docker_image_prefix = project_name.toLowerCase()
    }

    stages {
        stage('Destroy EKS') {
            steps {
                dir("eks") {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: "jenkins",
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        script {
                            // Get tf output
                            sh "aws s3 cp s3://$s3_bucket/env:/${environment.toLowerCase()}/tf_info.json ."
                            def tf_info = readJSON file: 'tf_info.json'
                            def aws_account_id = sh(
                                script: 'aws sts get-caller-identity --query "Account" --output text',
                                returnStdout: true
                            ).trim()
                            // teardown eks cluster
                            sh "eksctl delete cluster --name ${tf_info.eks_cluster_name} --region $region"
                            sh "aws cloudformation wait stack-delete-complete --stack-name eksctl-${tf_info.eks_cluster_name}-cluster"
                        }
                    }
                }
            }
        }
    }
}

