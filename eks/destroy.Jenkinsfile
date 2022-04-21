#!groovy

def project_name = 'AB-utopia'

pipeline {
    agent any

    environment {
        // Currently using single-tenancy architecture where build account is dev account
        ENVIRONMENT = 'dev'
        // TODO: test mutli-region deployment
        AWS_REGION = 'us-west-2'

        S3_PATH = "${project_name.toLowerCase()}/env:/$ENVIRONMENT/tf_info.json"
    }

    stages {
        stage('Detach FluentBit IAM Role') {
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
                            sh "aws s3 cp s3://$S3_PATH ./tf_info.json"
                            def tf_info = readJSON file: 'tf_info.json'
                            sh "aws eks --region $AWS_REGION update-kubeconfig --name ${tf_info.eks_cluster_name}"
                            def aws_account_id = sh(
                                script: 'aws sts get-caller-identity --query "Account" --output text',
                                returnStdout: true
                            ).trim()
                            def pod_exec_role = sh(
                                script: "CLUSTER_NAME=${tf_info.eks_cluster_name} ./pod-exec-role.sh",
                                returnStdout: true
                            )
                            sh """
                                aws iam detach-role-policy \
                                    --policy-arn arn:aws:iam::${aws_account_id}:policy/FluentBitEKSFargate \
                                    --role-name $pod_exec_role
                            """
                        }
                    }
                }
            }
        }
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
                            def tf_info = readJSON file: 'tf_info.json'
                            def aws_account_id = sh(
                                script: 'aws sts get-caller-identity --query "Account" --output text',
                                returnStdout: true
                            ).trim()
                            // teardown eks cluster
                            sh "eksctl delete cluster --name ${tf_info.eks_cluster_name} --region $AWS_REGION"
                            sh "aws cloudformation wait stack-delete-complete --stack-name eksctl-${tf_info.eks_cluster_name}-cluster"
                        }
                    }
                }
            }
        }
    }
}

