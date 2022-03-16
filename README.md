# Utopia Airlines IaC for AWS

## Initial Resources
- Route53 domain
- IAM user for Jenkins
- S3 bucket
- Secrets
- ECR repositories
- DynamoDB table `(TODO: include in terraform pipelines)`

## Jenkins Pipelines
### Deploy/Destroy base infrastructure with Terraform
(deploy pipeline is idempotent)
- Network components (VPC, subnets, etc.)
- RDS instance
- Secrets manager
- Bastion host for DB provisioning
- TLS certificate & validating R53 record
- Assocated IAM policies & security groups
### Deploy/Destroy EKS cluster and associated resources
- EKS nodes
- Application load balancer
- Route53 record
### Continuous microservice Integration & Deployment
1. Package with Maven
2. Analyze with SonarQube
3. Build container and tag with Docker
4. Push container to ECR
5. Perform a rolling update to the EKS cluster

## Cloud Storage
### S3 bucket
- Stores the SQL query script to provision an empty database schema
  `s3://<bucket>/schema.sql`/
- Allows for a Terraform state file of the current Terraform workspace to be stored and re-used on the apply and destroy stages
  `s3://<bucket>/:env/<Dev|Staging|Prod>/terraform.tfstate`
### DynamoDB
Used for Terraform state locking to prevent issues caused by concurrent Terraform operations.
### Secrets Manager
Stores the root and user database credentials along with the JWT secret in a key-value type secret
- `db_root_username`
- `db_root_password`
- `db_username`
- `db_password`
- `jwt_secret` (symmetric key)
### RDS
Created with Terraform and provisioned with a EC2 instance using the `user_data` field
- Creates empty database schema from SQL script stored in S3 bucket
- Inserts user roles used for RBAC via the RESTful API
- Adds database user that is used by microservices
### Certificate Manager
Stores key information for TLS certificate verification
