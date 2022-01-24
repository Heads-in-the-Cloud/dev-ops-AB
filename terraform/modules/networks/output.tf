output "db_subnet_group_id" {
  value = aws_db_subnet_group.default.id
}

output "public_subnet_ids" {
  value = [ for subnet in aws_subnet.public : subnet.id ]
}

output "domain" {
  value = aws_route53_record.default.name
}

output "alb_id" {
  value = aws_lb.default.name
}
