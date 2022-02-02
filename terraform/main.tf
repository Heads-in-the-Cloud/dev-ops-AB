# ECR Repositories
data "aws_ecr_repository" "reverse_proxy" {
  name = format("%s-reverse-proxy", lower(var.project_id))
}

data "aws_ecr_repository" "users_microservice" {
  name = format("%s-users-microservice", lower(var.project_id))
}

data "aws_ecr_repository" "flights_microservice" {
  name = format("%s-flights-microservice", lower(var.project_id))
}

data "aws_ecr_repository" "bookings_microservice" {
  name = format("%s-bookings-microservice", lower(var.project_id))
}

# Key/Value pairs of root db creds, microservice user creds, and the JWT secret
data "aws_secretsmanager_secret_version" "default" {
  secret_id = "${var.environment}/${var.project_id}/default"
}

locals {
  secrets            = jsondecode(data.aws_secretsmanager_secret_version.default.secret_string)
  vpc_cidr_block     = "10.0.0.0/16"
  subnet_cidr_blocks = {
      # Private: w/o NAT gateway
      private     = ["10.0.0.0/24", "10.0.1.0/24"]
      # Private: w/ NAT gateway
      nat_private = ["10.0.2.0/24", "10.0.3.0/24"]
      # Public: w/ Internet gateway
      public      = ["10.0.4.0/24", "10.0.5.0/24"]
  }
}

# Selects a random availability zone for each subnet in the given region
module "network" {
  source             = "./modules/network"
  project_id         = var.project_id
  vpc_cidr_block     = local.vpc_cidr_block
  subnet_cidr_blocks = local.subnet_cidr_blocks
  support_eks        = true
}

# RDS instance
module "rds" {
  source            = "./modules/rds"
  project_id        = var.project_id
  environment       = var.environment
  allocated_storage = 10
  instance_class    = "db.t2.micro"
  name              = "utopia"
  engine_version    = "8.0"
  engine            = "mysql"
  vpc               = {
    id         = module.network.vpc_id
    cidr_block = local.vpc_cidr_block
  }
  subnet_ids = module.network.subnet_ids.private
  secret_id  = data.aws_secretsmanager_secret_version.default.secret_id
}

# Bastion host on public subnet that initially connects to RDS instance to create schema and add the microservice user

data "aws_iam_policy" "read_s3" {
  arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "random_shuffle" "bastion_subnet_id" {
  input        = module.network.subnet_ids.public
  result_count = 1
}

module "bastion" {
  source        = "./modules/bastion"
  policy_arn    = data.aws_iam_policy.read_s3.arn
  instance_type = "t2.micro"
  vpc_id        = module.network.vpc_id
  subnet_id     = random_shuffle.bastion_subnet_id.result[0]
  user_data     = templatefile("${path.root}/user_data.sh", {
    s3_bucket        = lower(var.project_id)
    db_host          = module.rds.instance_address
    db_root_username = local.secrets.db_root_username
    db_root_password = local.secrets.db_root_password
    db_username      = local.secrets.db_username
    db_password      = local.secrets.db_password
  })

  project_id = var.project_id
}

#module "eks" {
#  source      = "./modules/eks"
#  project_id  = var.project_id
#  environment = var.environment
#  vpc_id        = module.network.vpc_id
#  subnet_ids  = {
#    eks_node_group = module.network.subnet_ids.private
#    eks            = concat(
#      module.network.subnet_ids.private,
#      module.network.subnet_ids.nan_private,
#      module.network.subnet_ids.public
#    )
#  }
#}
