provider "aws" {
  region = "us-west-2"
}

data "aws_ecr_repository" "users-microservice" {
  name = "ab-users-microservice"
}

data "aws_ecr_repository" "flights-microservice" {
  name = "ab-flights-microservice"
}

data "aws_ecr_repository" "bookings-microservice" {
  name = "ab-bookings-microservice"
}

data "aws_vpc" "default" {
  id = "${var.default_vpc_id}"
}

module "networks" {
  source              = "./modules/networks"
  vpc_cidr_block      = "10.6.0.0/16"
  subnet_1_cidr_block = "10.6.1.0/24"
  subnet_2_cidr_block = "10.6.2.0/24"
  subnet_3_cidr_block = "10.6.3.0/24"
  subnet_4_cidr_block = "10.6.4.0/24"
  rt_cidr_block       = "0.0.0.0/0"
  vpc_id              = data.aws_vpc.default.id
}

data "aws_secretsmanager_secret_version" "db_creds" {
  secret_id = "dev/Austin/db_creds"
}

locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.db_creds.secret_string
  )
}

module "rds" {
  source           = "./modules/rds"
  subnet_group_id  = module.networks.db_subnet_group_id
  public_subnet_id = element(module.networks.public_subnet_ids, 1)
  vpc_id           = data.aws_vpc.default.id
  db_root_username = local.db_creds.root_username
  db_root_password = local.db_creds.root_password
  db_username      = local.db_creds.username
  db_password      = local.db_creds.password
}
