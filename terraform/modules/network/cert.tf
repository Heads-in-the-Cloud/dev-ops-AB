data "aws_route53_zone" "default" {
  name = "hitwc.link"
}

resource "aws_acm_certificate" "default" {
  domain_name       = format("%s.hitwc.link", lower(var.project_id))
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.default.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.default.zone_id
}

resource "aws_acm_certificate_validation" "default" {
  certificate_arn         = aws_acm_certificate.default.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}

#resource "aws_cloudfront_distribution" "s3_distribution" {
#  ...
#  aliases = [ format("%s.hitwc.link", lower(var.project_id)) ]
#  viewer_certificate {
#    acm_certificate_arn      = aws_acm_certificate_validation.default.certificate_arn
#    minimum_protocol_version = "TLSv2"
#    ssl_support_method       = "sni-only"
#  }
#}
