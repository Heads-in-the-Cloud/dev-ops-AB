output "subnet_ids" {
  value = {
    private = aws_subnet.private[*].id
    nat_private = aws_subnet.nat_private[*].id
    public  = aws_subnet.public[*].id
  }
}

output "vpc_id" {
  value = aws_vpc.default.id
}

output "alb_names" {
  value = aws_lb.default[*].name
}
output "alb_sec_group_id" {
  value = aws_security_group.default.id
}
output "tls_cert_arn" {
  value = aws_acm_certificate.default.arn
}
