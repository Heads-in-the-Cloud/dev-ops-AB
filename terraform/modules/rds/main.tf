resource "aws_db_subnet_group" "default" {
  name       = lower(var.name_prefix)
  subnet_ids = var.subnet_ids

  tags = {
    Name = var.name_prefix
  }
}

resource "aws_security_group" "default" {
  name        = "${var.name_prefix}_db"
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
    Name = "${var.name_prefix}-db"
  }
}
resource "aws_db_instance" "default" {
  allocated_storage      = var.allocated_storage
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  name                   = var.name
  username               = var.root_username
  password               = var.root_password
  skip_final_snapshot    = true
  identifier             = lower(var.name_prefix)
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [ aws_security_group.default.id ]
}

