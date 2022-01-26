output "subnet_ids" {
  value = object({
    private = [ for subnet in aws_subnet.public : subnet.id ]
    public = [ for subnet in aws_subnet.public : subnet.id ]
  })
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
