resource "aws_subnet" "private_1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_1_cidr_block
  availability_zone = var.area_zone_1
  tags = {
    Name = "AB_private_subnet_1"
  }
}


resource "aws_subnet" "private_2" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_2_cidr_block
  availability_zone = var.area_zone_2

  tags = {
    Name = "AB_private_subnet_1"
  }
}

resource "aws_subnet" "public_1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_3_cidr_block
  availability_zone = var.area_zone_1
  map_public_ip_on_launch = true

  tags = {
    Name = "AB_public_subnet_1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_4_cidr_block
  availability_zone = var.area_zone_2
  map_public_ip_on_launch = true

  tags = {
    Name = "AB_public_subnet_2"
  }
}


resource "aws_internet_gateway" "default" {
  vpc_id = var.vpc_id

  tags = {
    Name = "AB_default_ig"
  }
}

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = var.rt_cidr_block
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name = "AB_public_rt"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = var.vpc_id

  route = []

  tags = {
    Name = "AB_private_rt"
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
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_db_subnet_group" "default" {
  name       = "AB_default"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = {
    Name = "AB_default_db_sg"
  }
}
