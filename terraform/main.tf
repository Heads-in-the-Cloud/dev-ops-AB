provider "aws" {
  region = var.region
}

# ECR Repositories
data "aws_ecr_repository" "reverse_proxy" {
  name = format("reverse-proxy-%s", lower(var.project_id))
}

data "aws_ecr_repository" "users_microservice" {
  name = format("users-microservice-%s", lower(var.project_id))
}

data "aws_ecr_repository" "flights_microservice" {
  name = format("flights-microservice-%s", lower(var.project_id))
}

data "aws_ecr_repository" "bookings_microservice" {
  name = format("bookings-microservice-%s", lower(var.project_id))
}

# Key/Value pairs of root db creds, microservice user creds, and the JWT secret
data "aws_secretsmanager_secret_version" "default" {
  secret_id = "${var.environment}/${var.project_id}/default"
}
locals {
  secrets = jsondecode(
    data.aws_secretsmanager_secret_version.default.secret_string
  )
}

resource "aws_vpc" "default" {
  cidr_block = "10.6.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "default-${var.project_id}"
  }
}

# Dynamically allocates a subnet per availability zone of the given region
module "networks" {
  source         = "./modules/networks"
  vpc_cidr_block = aws_vpc.default.cidr_block
  vpc_id         = aws_vpc.default.id
  rt_cidr_block  = "0.0.0.0/0"
  project_id     = var.project_id
}

# MySQL schema creation scripts
# TODO: uncomment if method of schema-creation changes
#resource "aws_s3_bucket" "db_init" {
#  bucket = format("db-init-%s", lower(var.project_id))
#  acl    = "private"
#
#  tags = {
#    Name = "db-init-${var.project_id}"
#  }
#}

# RDS instance
module "rds" {
  source            = "./modules/rds"
  vpc_id            = aws_vpc.default.id
  vpc_cidr_block    = aws_vpc.default.cidr_block
  allocated_storage = 10
  instance_class    = "db.t2.micro"
  name              = "utopia"
  engine            = "mysql"
  engine_version    = "8.0"
  root_username     = local.secrets.db_root_username
  root_password     = local.secrets.db_root_password
  subnet_group_id   = module.networks.db_subnet_group_id
  project_id        = var.project_id
}

data "aws_iam_policy" "read_s3" {
  arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# Bastion host on public subnet that initially connects to RDS instance to create schema and add the microservice user
module "bastion" {
  source         = "./modules/bastion"
  policy_arn     = data.aws_iam_policy.read_s3.arn
  instance_type  = "t2.micro"
  vpc_id         = aws_vpc.default.id
  public_ssh_key = var.public_ssh_key
  subnet_id      = element(module.networks.public_subnet_ids, 1)
  user_data      = templatefile("${path.root}/user_data.sh", {
    s3_bucket        = format("db-init-%s", lower(var.project_id))#aws_s3_bucket.db_init.bucket
    db_host          = module.rds.instance_address
    db_root_username = local.secrets.db_root_username
    db_root_password = local.secrets.db_root_password
    db_username      = local.secrets.db_username
    db_password      = local.secrets.db_password
  })

  project_id = var.project_id
}
