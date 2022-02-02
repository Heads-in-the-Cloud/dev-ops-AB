output "subnet_ids" {
  value = {
    private = aws_subnet.private[*].id
    nat_private = aws_subnet.nat_private[*].id
    public  = aws_subnet.public[*].id
  }
}

output "domain" {
  value = aws_route53_record.default.name
}

output "vpc_id" {
  value = aws_vpc.default.id
}

output "alb_id" {
  value = aws_lb.default.name
}

output "alb_sec_group_id" {
  value = aws_security_group.default.id
}
