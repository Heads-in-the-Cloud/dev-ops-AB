data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "default" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = var.project_id
  }
}

resource "random_shuffle" "public_azs" {
  input        = data.aws_availability_zones.available.names
  result_count = length(var.subnet_cidr_blocks.public)
}

resource "random_shuffle" "private_azs" {
  input        = data.aws_availability_zones.available.names
  result_count = length(var.subnet_cidr_blocks.private)
}

resource "aws_subnet" "private" {
  count                   = length(var.subnet_cidr_blocks.private)
  vpc_id                  = aws_vpc.default.id
  cidr_block              = var.subnet_cidr_blocks.private[count.index]
  availability_zone       = random_shuffle.private_azs.result[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = format("private-%d-%s", count.index + 1, var.project_id)
    "kubernetes.io/cluster/default-${var.project_id}" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.subnet_cidr_blocks.public)
  vpc_id                  = aws_vpc.default.id
  cidr_block              = var.subnet_cidr_blocks.public[count.index]
  availability_zone       = random_shuffle.public_azs.result[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = format("public-%d-%s", count.index + 1, var.project_id)
    "kubernetes.io/cluster/default-${var.project_id}" = "shared"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = var.project_id
  }
}

resource "aws_eip" "nat" {
  vpc        = true
  depends_on = [ aws_internet_gateway.default ]

  tags = {
    Name     = "nat-${var.project_id}"
  }
}

resource "random_shuffle" "nat_public_subnet_id" {
  input        = aws_subnet.public[*].id
  result_count = 1
}

resource "aws_nat_gateway" "default" {
  allocation_id = aws_eip.nat.id
  subnet_id     = random_shuffle.nat_public_subnet_id.result[0]
  depends_on    = [ aws_internet_gateway.default ]

  tags = {
    Name = var.project_id
  }
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.default.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = var.rt_cidr_block
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name = "public-${var.project_id}"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "private-${var.project_id}"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
