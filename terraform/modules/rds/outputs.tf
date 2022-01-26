output "instance_address" {
  value = aws_db_instance.default.address
}
output "security_group_id" {
  value = aws_security_group.default.id
}
