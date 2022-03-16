resource "aws_subnet" "nat_private" {
  count                   = local.num_availability_zones
  vpc_id                  = aws_vpc.default.id
  cidr_block              = cidrsubnet(aws_vpc.default.cidr_block, 8, count.index + local.num_availability_zones)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name = format("%s-nat-private-%d", var.name_prefix, count.index + 1)
    },
    [var.support_eks ? {
      "kubernetes.io/role/internal-elb" = 1,
      #TODO: set on EKS deployment
      "kubernetes.io/cluster/${var.name_prefix}" = "shared"
    } : null]...
  )
}

resource "aws_eip" "nat" {
  vpc        = true
  depends_on = [ aws_internet_gateway.default ]

  tags = {
    Name = format("%s-nat", var.name_prefix)
  }
}

resource "aws_nat_gateway" "default" {
  count         = length(aws_subnet.nat_private)
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[count.index].id
  depends_on    = [ aws_internet_gateway.default ]

  tags = {
    Name = format("%s-%d", var.name_prefix, count.index + 1)
  }
}

resource "aws_route_table" "nat_private" {
  count  = length(aws_subnet.nat_private)
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "${var.name_prefix}-nat-private-${count.index}"
  }
}

resource "aws_route_table_association" "nat_private" {
  count          = length(aws_subnet.nat_private)
  subnet_id      = aws_subnet.nat_private[count.index].id
  route_table_id = aws_route_table.nat_private[count.index].id
}

resource "aws_route" "nat_gateway" {
  count                  = length(aws_nat_gateway.default)
  route_table_id         = aws_route_table.nat_private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.default[count.index].id
}
