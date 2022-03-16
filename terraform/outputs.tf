output "vpc_id" {
  value = module.network.vpc_id
}
output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}
output "nat_private_subnet_ids" {
  value = module.network.nat_private_subnet_ids
}
output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}
output "db_url" {
  value = module.rds.instance_address
}
output "acm_cert_arn" {
  value = module.dns.acm_cert_arn
}
output "r53_zone_id" {
 value = module.dns.r53_zone_id
}
output "external_dns_policy" {
 value = module.dns.external_dns_policy
}
