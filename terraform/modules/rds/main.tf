resource "aws_db_instance" "default" {
  allocated_storage      = var.allocated_storage
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  name                   = var.name
  username               = var.root_username
  password               = var.root_password
  skip_final_snapshot    = true
  identifier             = format("db-%s", lower(var.project_id))
  db_subnet_group_name   = var.subnet_group_id
  vpc_security_group_ids = [ aws_security_group.db.id ]
}

resource "aws_security_group" "db" {
  name        = "db_${var.project_id}"
  description = "Inbound to only 3306"
  vpc_id      = var.vpc_id

  ingress {
    description = "MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [ var.vpc_cidr_block ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }

  tags = {
    Name = "db-${var.project_id}"
  }
}
