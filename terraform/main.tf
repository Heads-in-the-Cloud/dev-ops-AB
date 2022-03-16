data "aws_availability_zones" "available" {
  state = "available"
}

# Key/Value pairs of root db creds, microservice user creds, and the JWT symmetric key
data "aws_secretsmanager_secret_version" "default" {
  secret_id = "${var.environment}/${var.name_prefix}/default"
}

locals {
  # At least two subnets are required for the RDS instance
  min_num_availability_zones = 2
  max_num_availability_zones = length(data.aws_availability_zones.available.names)
  subdomain = "${var.subdomain_prefix}.${var.domain}"
  secrets   = jsondecode(data.aws_secretsmanager_secret_version.default.secret_string)
}

data "assert_test" "num_availability_zones" {
  test = var.num_availability_zones >= local.min_num_availability_zones && var.num_availability_zones <= local.max_num_availability_zones
  throw = format(
    "Invalid number of availabaility zones, must be between %d and %d",
    local.min_num_availability_zones,
    local.max_num_availability_zones
  )
}

# TLS cert & IAM policy for updating Route53 record with external-dns
module "cert" {
  source      = "./modules/cert"
  name_prefix = var.name_prefix
  domain_name = local.subdomain
}

# ECR Repositories
data "aws_ecr_repository" "reverse_proxy" {
  name = format("%s-reverse-proxy", lower(var.name_prefix))
}

data "aws_ecr_repository" "users_microservice" {
  name = format("%s-users-microservice", lower(var.name_prefix))
}

data "aws_ecr_repository" "flights_microservice" {
  name = format("%s-flights-microservice", lower(var.name_prefix))
}

data "aws_ecr_repository" "bookings_microservice" {
  name = format("%s-bookings-microservice", lower(var.name_prefix))
}

# Selects a random availability zone for each subnet in the given region
module "network" {
  source             = "./modules/network"
  name_prefix        = var.name_prefix
  vpc_cidr_block     = var.vpc_cidr_block
  tls_subdomain      = lower(var.name_prefix)
  availability_zones = slice(data.aws_availability_zones.available.names, 0, var.num_availability_zones)
  support_eks        = true
}

# RDS instance
module "rds" {
  source            = "./modules/rds"
  name_prefix       = var.name_prefix
  allocated_storage = 10
  instance_class    = "db.t2.micro"
  name              = "utopia"
  engine_version    = "8.0"
  engine            = "mysql"
  vpc               = {
    id         = module.network.vpc_id
    cidr_block = var.vpc_cidr_block
  }
  subnet_ids    = module.network.private_subnet_ids
  root_username = local.secrets.db_root_username
  root_password = local.secrets.db_root_password
}

# Bastion host on public subnet that initially connects to RDS instance to create schema and add the microservice user
data "aws_iam_policy" "read_s3" {
  arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "random_shuffle" "bastion_subnet_id" {
  input        = module.network.public_subnet_ids
  result_count = 1
}

module "bastion" {
  source        = "./modules/bastion"
  policy_arn    = data.aws_iam_policy.read_s3.arn
  instance_type = "t2.micro"
  vpc_id        = module.network.vpc_id
  subnet_id     = random_shuffle.bastion_subnet_id.result[0]
  user_data     = templatefile("${path.root}/user_data.sh", {
    VPC_CIDR_BLOCK   = var.vpc_cidr_block
    S3_BUCKET        = var.s3_bucket
    DB_HOST          = module.rds.instance_address
    DB_ROOT_USERNAME = local.secrets.db_root_username
    DB_ROOT_PASSWORD = local.secrets.db_root_password
    DB_USER_USERNAME = local.secrets.db_username
    DB_USER_PASSWORD = local.secrets.db_password
  })

  name_prefix = var.name_prefix
}
