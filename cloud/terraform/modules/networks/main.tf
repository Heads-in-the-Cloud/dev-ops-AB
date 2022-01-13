data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "private_1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_1_cidr_block
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "ab_private_subnet_1"
    "kubernetes.io/cluster/ab" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_2_cidr_block
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "ab_private_subnet_2"
    "kubernetes.io/cluster/ab" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_subnet" "public_1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_3_cidr_block
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "ab_public_subnet_1"
    "kubernetes.io/cluster/ab" = "shared"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_subnet" "public_2" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_4_cidr_block
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "ab_public_subnet_2"
    "kubernetes.io/cluster/ab" = "shared"
    "kubernetes.io/role/elb" = 1
  }
}


resource "aws_internet_gateway" "default" {
  vpc_id = var.vpc_id

  tags = {
    Name = "ab_default_ig"
  }
}

resource "aws_eip" "nat" {
  vpc        = true
  depends_on = [aws_internet_gateway.default]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id
  depends_on    = [aws_internet_gateway.default]

  tags = {
    Name        = "ab_nat"
  }
}
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = var.rt_cidr_block
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name = "ab_public_rt"
  }
}

resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  route = []

  tags = {
    Name = "ab_private_rt"
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_db_subnet_group" "default" {
  name       = "ab_default"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = {
    Name = "ab_default_db_sg"
  }
}
