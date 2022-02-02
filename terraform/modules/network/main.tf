// Filtered list of all availablility zones in the region
data "aws_availability_zones" "available" {
  state = "available"
}

// VPC for all below network services
resource "aws_vpc" "default" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = var.project_id
  }
}

// Private subnet w/o nat gateway
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
    Name = format("%s-private-%d", var.project_id, count.index + 1)
  }
}

resource "aws_route_table" "private" {
  # Only create this resource if private subnets were specified
  count  = length(aws_subnet.private) != 0 ? 1 : 0
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "${var.project_id}-private"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

// Private subnet w/ nat gateway
resource "random_shuffle" "nat_private_azs" {
  input        = data.aws_availability_zones.available.names
  result_count = length(var.subnet_cidr_blocks.nat_private)
}

resource "aws_subnet" "nat_private" {
  count                   = length(var.subnet_cidr_blocks.nat_private)
  vpc_id                  = aws_vpc.default.id
  cidr_block              = var.subnet_cidr_blocks.nat_private[count.index]
  availability_zone       = random_shuffle.nat_private_azs.result[count.index]
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name = format("%s-nat-private-%d", var.project_id, count.index + 1)
    },
    #TODO: set on deployment from ansible
    #"kubernetes.io/cluster/${var.project_id}" = "shared"
    [var.support_eks ? {"kubernetes.io/role/internal-elb" = 1} : null]...
  )
}

resource "aws_route_table" "nat_private" {
  # Only create this resource if subnets for the nat gateway were specified
  count  = length(aws_subnet.nat_private) != 0 ? 1 : 0
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "${var.project_id}-nat-private"
  }
}

resource "aws_route_table_association" "nat_private" {
  count          = length(aws_subnet.nat_private)
  subnet_id      = aws_subnet.nat_private[count.index].id
  route_table_id = aws_route_table.nat_private.id
}

resource "aws_route" "nat_gateway" {
  # Only create this resource if subnets for the nat gateway were specified
  count                  = length(aws_subnet.nat_private) != 0 ? 1 : 0
  route_table_id         = aws_route_table.nat_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.default.id
}

// Public subnet w/ internet gateway
resource "random_shuffle" "public_azs" {
  input        = data.aws_availability_zones.available.names
  result_count = length(var.subnet_cidr_blocks.public)
}

resource "aws_subnet" "public" {
  count                   = length(var.subnet_cidr_blocks.public)
  vpc_id                  = aws_vpc.default.id
  cidr_block              = var.subnet_cidr_blocks.public[count.index]
  availability_zone       = random_shuffle.public_azs.result[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = format("%s-public-%d", var.project_id, count.index + 1)
    },
    #TODO: set on deployment from ansible
    #"kubernetes.io/cluster/${var.project_id}" = "shared"
    [var.support_eks ? {"kubernetes.io/role/elb" = 1} : null]...
  )
}

resource "aws_internet_gateway" "default" {
  # Only create this resource if public subnets were specified
  count = length(aws_subnet.public) != 0 ? 1 : 0
  vpc_id = aws_vpc.default.id

  tags = {
    Name = var.project_id
  }
}

# Single EIP used for NAT gateway
resource "aws_eip" "nat" {
  # Only create this resource if subnets for the nat gateway were specified
  count      = length(aws_subnet.nat_private) != 0 ? 1 : 0
  vpc        = true
  depends_on = [ aws_internet_gateway.default ]

  tags = {
    Name     = "${var.project_id}-nat"
  }
}

resource "random_shuffle" "nat_public_subnet_id" {
  # Only create this resource if there is a subnet for the nat_private subnet and public groups
  count        = length(aws_subnet.public) != 0 && length(aws_subnet.nat_private) != 0 ? 1 : 0
  input        = aws_subnet.public[*].id
  result_count = 1
}

resource "aws_nat_gateway" "default" {
  # Only create this resource if subnets for the nat gateway were specified
  count         = length(aws_subnet.nat_private) != 0 ? 1 : 0
  allocation_id = aws_eip.nat.id
  subnet_id     = random_shuffle.nat_public_subnet_id.result[0]
  depends_on    = [ aws_internet_gateway.default ]

  tags = {
    Name = var.project_id
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "public" {
  # Only create this resource if public subnets were specified
  count = length(aws_subnet.public) != 0 ? 1 : 0
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = var.ig_rt_cidr_block
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name = "${var.project_id}-public"
  }
}
