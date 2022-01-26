output "subnet_group_id" {
  value = aws_db_subnet_group.default.id
}
output "security_group_id" {
  value = aws_security_group.db.id
}
