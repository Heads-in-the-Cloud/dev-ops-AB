output "db_subnet_group_id" {
  value = aws_db_subnet_group.default.id
}

output "public_subnet_ids" {
  value = [ aws_subnet.public_1.id, aws_subnet.public_2.id ]
}
