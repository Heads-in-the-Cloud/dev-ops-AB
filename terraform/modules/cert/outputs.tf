output "tls_cert_arn" {
  value = aws_acm_certificate.default.arn
}
output "r53_zone_id" {
  value = data.aws_route53_zone.default.id
}
