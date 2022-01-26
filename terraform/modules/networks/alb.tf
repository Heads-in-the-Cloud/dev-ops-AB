// Application Load Balancer
resource "aws_security_group" "alb" {
  name        = "alb-${var.project_id}"
  description = "Open HTTP port"
  vpc_id      = aws_vpc.default.id

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

resource "aws_lb" "default" {
  name               = "default-${var.project_id}"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id
  security_groups    = [ aws_security_group.alb.id ]

  tags = {
    Name = var.project_id
  }
}

data "aws_route53_zone" "default" {
  name = "hitwc.link"
}

resource "aws_route53_record" "default" {
  zone_id = data.aws_route53_zone.default.zone_id
  name    = format("%s.hitwc.link", lower(var.project_id))
  type    = "CNAME"
  ttl     = "20"
  records = [ aws_lb.default.dns_name ]
}
