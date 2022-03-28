resource "aws_subnet" "public" {
  count                   = local.num_availability_zones
  vpc_id                  = aws_vpc.default.id
  cidr_block              = cidrsubnet(aws_vpc.default.cidr_block, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = format("%s-public-%d", var.name_prefix, count.index + 1)
    },
    [var.support_eks ? {
      "kubernetes.io/role/elb" = 1,
      #TODO: set on deployment
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    } : null]...
  )
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = var.name_prefix
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name = "${var.name_prefix}-public"
  }
}
