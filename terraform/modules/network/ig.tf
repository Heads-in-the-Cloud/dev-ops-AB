resource "aws_internet_gateway" "default" {
  # Only create this resource if public subnets were specified
  count = length(aws_subnet.public) != 0 ? 1 : 0
  vpc_id = aws_vpc.default.id

  tags = {
    Name = var.project_id
  }
}

// Application Load Balancer
resource "aws_security_group" "default" {
  name        = "${var.project_id}-alb"
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
    Name = "${var.project_id}-alb"
  }
}

resource "aws_lb" "default" {
  count              = length(var.alb_names)
  name               = var.alb_names[count.index]
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id
  security_groups    = [ aws_security_group.default.id ]
  depends_on         = [ aws_internet_gateway.default[0] ]

  tags = {
    Name = var.project_id
  }
}
