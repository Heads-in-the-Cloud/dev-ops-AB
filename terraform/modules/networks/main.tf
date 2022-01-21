data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "private" {
  count                   = "${length(data.aws_availability_zones.available.names)}"
  vpc_id                  = var.vpc_id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, count.index)
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = false

  tags = {
    Name = format("private-%d-AB", count.index + 1)
    "kubernetes.io/cluster/AB"        = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_subnet" "public" {
  count                   = "${length(data.aws_availability_zones.available.names)}"
  vpc_id                  = var.vpc_id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, count.index + 20)
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = true

  tags = {
    Name = format("public-%d-AB", count.index + 1)
    "kubernetes.io/cluster/AB" = "shared"
    "kubernetes.io/role/elb"   = 1
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = var.vpc_id

  tags = {
    Name = "default-AB"
  }
}

resource "aws_eip" "nat" {
  vpc        = true
  depends_on = [ aws_internet_gateway.default ]

  tags = {
    Name     = "nat-AB"
  }
}

resource "aws_nat_gateway" "default" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [ aws_internet_gateway.default ]

  tags = {
    Name        = "default-AB"
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
    Name = "public-AB"
  }
}

resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  route = []

  tags = {
    Name = "privagte-AB"
  }
}

resource "aws_route_table_association" "public" {
  count          = "${length(aws_subnet.public)}"
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = "${length(aws_subnet.private)}"
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_db_subnet_group" "default" {
  name       = "ab_default"
  subnet_ids = [ for subnet in aws_subnet.private : subnet.id ]

  tags = {
    Name = "AB_default_db_sg"
  }
}

resource "aws_security_group" "alb" {
  name = "AB-alb"
  description = "Open HTTP port"
  vpc_id = var.vpc_id

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port     = 0
    to_port       = 0
    protocol      = "-1"
    cidr_blocks   = [ "0.0.0.0/0" ]
  }

  tags = {
    Name = "alb-AB"
  }
}

// ECS Application Load Balancer
resource "aws_lb" "ecs" {
  name = "AB-ecs"
  internal = false
  load_balancer_type = "application"
  subnets = [ for subnet in aws_subnet.public : subnet.id ]
  security_groups = [ aws_security_group.alb.id ]

  tags = {
    Name = "ecs-AB"
  }
}

// Route 53 Hosted Zone
data "aws_route53_zone" "default" {
  name = "hitwc.link"
}

// ECS Route 53 Record
resource "aws_route53_record" "ecs" {
  zone_id = data.aws_route53_zone.default.zone_id
  name = "ecs.austin.hitwc.link"
  type = "CNAME"
  ttl = "20"
  records = [ aws_lb.ecs.dns_name ]
}
