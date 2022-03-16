output "vpc_id" {
  value = aws_vpc.default.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}
output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}
output "nat_private_subnet_ids" {
  value = aws_subnet.nat_private[*].id
}
