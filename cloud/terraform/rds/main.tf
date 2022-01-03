
resource "aws_db_instance" "rds" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t2.micro"
  name                   = "utopia"
  username               = var.db_username
  password               = var.db_password
  skip_final_snapshot    = true
  identifier             = "ab_db"
  db_subnet_group_name   = var.subnet_group_id
  vpc_security_group_ids = [ aws_security_group.db_sg.id ]
}

resource "aws_security_group" "db" {
  name        = "AB_db"
  description = "Inbound to only 3306"
  vpc_id      = var.vpc_id

  ingress {
    description = "MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.private_cidr_blocks
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "AB_db_sg"
  }
}
