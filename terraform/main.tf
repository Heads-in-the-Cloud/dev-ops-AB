provider "aws" {
  region = "${var.region}"
}

data "aws_ecr_repository" "api_gateway" {
  name = "ab-api-gateway"
}

data "aws_ecr_repository" "users_microservice" {
  name = "ab-users-microservice"
}

data "aws_ecr_repository" "flights_microservice" {
  name = "ab-flights-microservice"
}

data "aws_ecr_repository" "bookings_microservice" {
  name = "ab-bookings-microservice"
}

data "aws_vpc" "default" {
  id = "${var.vpc_id}"
}

module "networks" {
  source         = "./modules/networks"
  vpc_cidr_block = "10.6.0.0/16"
  vpc_id         = var.vpc_id
  rt_cidr_block  = "0.0.0.0/0"
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
  vpc_cidr_block   = "10.6.0.0/16"
  db_root_username = local.db_creds.root_username
  db_root_password = local.db_creds.root_password
  db_username      = local.db_creds.username
  db_password      = local.db_creds.password
}
