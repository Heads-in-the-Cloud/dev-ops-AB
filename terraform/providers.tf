terraform {
  #required_version = "0.14.10"

  backend "local" {}
}

provider "aws" {
  region                      = var.region
  s3_force_path_style         = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    cloudformation = "http://localhost:4581"
    cloudwatch     = "http://localhost:4582"
    dynamodb       = "http://localhost:4569"
    ec2            = "http://localhost:4597"
    ecr            = "http://localhost:4510"
    iam            = "http://localhost:4593"
    kinesis        = "http://localhost:4568"
    kms            = "http://localhost:4599"
    lambda         = "http://localhost:4574"
    redshift       = "http://localhost:4577"
    route53        = "http://localhost:4580"
    s3             = "http://localhost:4572"
    ses            = "http://localhost:4579"
    sns            = "http://localhost:4575"
    sqs            = "http://localhost:4576"
    ssm            = "http://localhost:4583"
    sts            = "http://localhost:4592"
    stepfunctions  = "http://localhost:4585"
  }
}
