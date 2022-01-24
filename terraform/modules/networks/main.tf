data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "private" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = var.vpc_id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = format("private-%d-%s", count.index + 1, var.project_id)
    "kubernetes.io/cluster/default-${var.project_id}" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_subnet" "public" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = var.vpc_id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, count.index + 20)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = format("public-%d-%s", count.index + 1, var.project_id)
    "kubernetes.io/cluster/default-${var.project_id}" = "shared"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = var.vpc_id

  tags = {
    Name = "default-${var.project_id}"
  }
}

resource "aws_eip" "nat" {
  vpc        = true
  depends_on = [ aws_internet_gateway.default ]

  tags = {
    Name     = "nat-${var.project_id}"
  }
}

resource "aws_nat_gateway" "default" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [ aws_internet_gateway.default ]

  tags = {
    Name = "default-${var.project_id}"
  }
}
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.default.id
}

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = var.rt_cidr_block
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name = "public-${var.project_id}"
  }
}

resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  //route = []

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

resource "aws_db_subnet_group" "default" {
  name       = format("private_%s", lower(var.project_id))
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "default-${var.project_id}"
  }
}

resource "aws_security_group" "alb" {
  name        = "alb-${var.project_id}"
  description = "Open HTTP port"
  vpc_id      = var.vpc_id

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    Name = "alb-${var.project_id}"
  }
}

// Application Load Balancer
resource "aws_lb" "default" {
  name               = "default-${var.project_id}"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id
  security_groups    = [ aws_security_group.alb.id ]

  tags = {
    Name = "default-${var.project_id}"
  }
}

data "aws_route53_zone" "default" {
  name = "hitwc.link"
}

resource "aws_route53_record" "default" {
  zone_id = data.aws_route53_zone.default.zone_id
  name    = format("utopia-%s.hitwc.link", lower(var.project_id))
  type    = "CNAME"
  ttl     = "20"
  records = [ aws_lb.default.dns_name ]
}
