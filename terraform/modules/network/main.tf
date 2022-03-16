locals {
  num_availability_zones = length(var.availabaility_zones)
}

// VPC for all below network services
resource "aws_vpc" "default" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = var.name_prefix
  }
}
