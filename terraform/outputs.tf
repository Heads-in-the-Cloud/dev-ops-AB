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
output "mysql_url" {
  value = "${module.rds.instance_address}:${local.db_port}/${local.db_name}"
}
output "acm_cert_arn" {
  value = module.cert.tls_cert_arn
}
output "r53_zone_id" {
 value = module.cert.r53_zone_id
}
output "subdomain_prefix" {
 value = var.subdomain_prefix
}
output "domain" {
 value = var.domain
}
