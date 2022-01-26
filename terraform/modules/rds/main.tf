resource "aws_db_subnet_group" "default" {
  name       = lower(var.project_id)
  subnet_ids = var.subnet_ids[*]

  tags = {
    Name = var.project_id
  }
}

resource "aws_security_group" "db" {
  name        = "${var.project_id}_db"
  description = "Inbound to only 3306"
  vpc_id      = var.vpc.id

  ingress {
    description = "MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [ var.vpc.cidr_block ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }

  tags = {
    Name = "${var.project_id}-db"
  }
}

module "init-lambda" {
  source = "./init-lambda"
  project_id = var.project_id
}
