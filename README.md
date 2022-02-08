# Utopia Airlines Cloud Deployment Config

## Cloud Storage
### S3 buckets
- Allows for a Terraform state file of the current Terraform workspace to be stored and re-used on the apply and destroy stages
  `s3://<bucket>/:env/<Dev|Staging|Prod>/terraform.tfstate`
- The outputs provided after applying Terraform are stored in a json file for the specified environment
  `s3://<bucket>/:env/<Dev|Staging|Prod>/output.json`
### AWS Secrets Manager
 - Stores the root and user database credentials along with the JWT secret in a key-value type secret
   - `db_root_username`
   - `db_root_password`
   - `db_username`
   - `db_password`
   - `jwt_token`
### RDS
 - Instance created with Terraform and provisioned with a bastion using `user_data` to create the database schema and create a database user

## Terraform: Base Infrastructure
[![Build Status](https://jenkins1.hitwc.link/buildStatus/icon?job=Austin%2FTerraform)](https://jenkins1.hitwc.link/job/Austin/job/Terraform/)

## ECS: Cluster deployed using Docker context
[![Build Status](https://jenkins1.hitwc.link/buildStatus/icon?job=Austin%2FECS)](https://jenkins1.hitwc.link/job/Austin/job/ECS/)

## EKS: Cluster declared using Terraform and provisioned using Ansible
[![Build Status](https://jenkins1.hitwc.link/buildStatus/icon?job=Austin%2FEKS)](https://jenkins1.hitwc.link/job/Austin/job/EKS/)
