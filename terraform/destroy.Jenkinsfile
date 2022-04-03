#!groovy

def project_id = 'AB-utopia'

def vars = [
    'region': 'us-west-2',
    'project_id': project_id,
    'environment': 'dev',
    'vpc_cidr_block': '10.0.0.0/16',
    'num_availability_zones': 2,
    'domain': 'hitwc.link',
    's3_bucket': project_id.toLowerCase(),
    'subdomain_prefix': project_id.toLowerCase(),
]

pipeline {
    agent any

    stages {
        stage('Init & Plan') {
            steps {
                dir("terraform") {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'jenkins',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        script {
                            sh """
                                terraform init \
                                    -backend-config='bucket=${vars.s3_bucket}' \
                                    -backend-config='region=${vars.region}' \
                                    -backend-config='encrypt=true'
                            """
                            sh "terraform workspace select ${vars.environment} || terraform workspace new ${vars.environment}"

                            def vars_as_cli_args = vars.keySet().collect{ key -> "-var \'${key}=${vars.get(key)}\' " }.join()

                            sh "terraform plan -destroy -input=false -out=tfplan $vars_as_cli_args"
                        }
                    }
                    sh 'terraform show tfplan'
                }
            }
        }

        stage('Apply') {
            steps {
                dir("terraform") {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'jenkins',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh 'terraform apply -input=false tfplan'
                    }
                }
            }
        }
    }
}
