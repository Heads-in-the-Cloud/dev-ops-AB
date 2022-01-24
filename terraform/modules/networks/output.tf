output "db_subnet_group_id" {
  value = aws_db_subnet_group.private.id
}

output "public_subnet_ids" {
  value = [ for subnet in aws_subnet.public : subnet.id ]
}
