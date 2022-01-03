resource "aws_instance" "db_bastion" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.ubuntu.id
  vpc_security_group_ids = []
  subnet_id              = aws_subnet.public_1.id
  private_ip             = "10.6.3.1"

  #user_data = templatefile("user_data.tftpl", {
  #  admin_username = var.db_username
  #  admin_password = var.db_password
  #})

  tags = {
    Name = "AB_db_bastion"
  }
}

resource "aws_security_group" "bastion" {
  name        = "AB_bastion"
  description = "Inbound to only 3306"
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
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "AB_bastion_sg"
  }
}
