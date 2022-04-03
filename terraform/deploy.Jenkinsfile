#!groovy

def vars = [
    'region': 'us-west-2',
    'project_id': 'AB-utopia',
    'environment': 'dev',
    'vpc_cidr_block': '10.0.0.0/16',
    'num_availability_zones': 2,
    'domain': 'hitwc.link',
    's3_bucket': $project_id.toLowerCase(),
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

                            def vars_as_cli_args = vars.keySet().collect{ key -> "-var '${key}=${vars.get(${key})}' " }

                            sh "terraform plan -input=false -out=tfplan $vars_as_cli_args"
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
                        sh 'terraform output -json | jq "with_entries(.value |= .value)" > output_values.json'
                        sh "aws s3 cp output_values.json s3://${vars.s3_bucket}/env:/${vars.environment}/tf_info.json"
                    }
                }
            }
        }
    }
}
