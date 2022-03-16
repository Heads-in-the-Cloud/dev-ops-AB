#!groovy
pipeline {
    agent any

    environment {
        project_name = "AB-utopia"
        environmment = "dev"

        cluster_name        = project_name
        domain              = "hitwc.link"
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
                            sh "aws s3 cp s3://$s3_bucket/$environment:/tf_output.json ."
                            // teardown eks cluster
                            def region = sh(
                                script: 'aws configure get region',
                                returnStdout: true
                            ).trim()
                            sh "eksctl delete cluster --name $cluster_name --region $region"
                        }
                    }
                }
            }
        }
    }
}

