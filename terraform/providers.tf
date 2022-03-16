/* -------------------------------------------------------------------------- */
/*                             AWS configuration                              */
/* -------------------------------------------------------------------------- */

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    assert = {
      source  = "bwoznicki/assert"
      version = "= 0.0.1"
    }
  }
}

provider "aws" {
  region = var.region
}

/* -------------------------------------------------------------------------- */
/*                          Localstack configuration                          */
/* -------------------------------------------------------------------------- */

#provider "aws" {
#
#  access_key                  = "local"
#  secret_key                  = "local"
#  region                      = var.region
#  s3_force_path_style         = true
#  skip_credentials_validation = true
#  skip_metadata_api_check     = true
#  skip_requesting_account_id  = true
#
#  endpoints {
#    cloudwatch     = "http://localhost:4566"
#    ec2            = "http://localhost:4566"
#    ecr            = "http://localhost:4566"
#    elbv2          = "http://localhost:4566"
#    iam            = "http://localhost:4566"
#    rds            = "http://localhost:4566"
#    route53        = "http://localhost:4566"
#    s3             = "http://localhost:4566"
#    secretsmanager = "http://localhost:4566"
#  }
#}
