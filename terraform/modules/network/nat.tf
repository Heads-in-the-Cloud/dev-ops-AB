# Single EIP used for NAT gateway
resource "aws_eip" "nat" {
  # Only create this resource if subnets for the nat gateway were specified
  count      = length(aws_subnet.nat_private) != 0 ? 1 : 0
  vpc        = true
  depends_on = [ aws_internet_gateway.default[0] ]

  tags = {
    Name     = "${var.project_id}-nat"
  }
}

resource "random_shuffle" "nat_public_subnet_id" {
  # Only create this resource if there is a subnet for the nat_private subnet and public groups
  count        = length(aws_subnet.public) != 0 && length(aws_subnet.nat_private) != 0 ? 1 : 0
  input        = aws_subnet.public[*].id
  result_count = 1
}

resource "aws_nat_gateway" "default" {
  # Only create this resource if subnets for the nat gateway were specified
  count         = length(aws_subnet.nat_private) != 0 ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = random_shuffle.nat_public_subnet_id[0].result[0]
  depends_on    = [ aws_internet_gateway.default[0] ]

  tags = {
    Name = var.project_id
  }
}
