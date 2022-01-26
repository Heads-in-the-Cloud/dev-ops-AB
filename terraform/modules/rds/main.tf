resource "aws_db_subnet_group" "default" {
  name       = lower(var.project_id)
  subnet_ids = var.subnet_ids[*]

  tags = {
    Name = var.project_id
  }
}

data "aws_secretsmanager_secret_version" "default" {
  secret_id = var.secret_id
}
locals {
  secrets = jsondecode(data.aws_secretsmanager_secret_version.default.secret_string)
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
resource "aws_db_instance" "default" {
  allocated_storage      = var.allocated_storage
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  name                   = var.name
  username               = local.secrets.root_username
  password               = local.secrets.root_password
  skip_final_snapshot    = true
  identifier             = lower(var.project_id)
  db_subnet_group_name   = var.subnet_group_id
  vpc_security_group_ids = [ aws_security_group.default.id ]
}

