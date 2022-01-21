resource "aws_db_instance" "default" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t2.micro"
  name                   = "utopia"
  username               = var.db_root_username
  password               = var.db_root_password
  skip_final_snapshot    = true
  identifier             = "ab-db"
  db_subnet_group_name   = var.subnet_group_id
  vpc_security_group_ids = [ aws_security_group.db.id ]
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
    Name = "db-AB"
  }
}

# Latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "bastion" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.amazon_linux_2.id
  vpc_security_group_ids = [ aws_security_group.ssh.id ]
  subnet_id              = var.public_subnet_id
  key_name               = var.key_name

  user_data = templatefile("${path.module}/user_data.sh", {
    db_host          = aws_db_instance.default.address
    db_root_username = var.db_root_username
    db_root_password = var.db_root_password
    db_username      = var.db_username
    db_password      = var.db_password
  })

  tags = {
    Name = "bastion-AB"
  }
}

resource "aws_security_group" "ssh" {
  name        = "AB_bastion"
  description = "Inbound to only 22 from anywhere"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }

  tags = {
    Name = "ssh-AB"
  }
}
