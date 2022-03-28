output "vpc_id" {
  value = module.network.vpc_id
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
output "eks_cluster_name" {
 value = local.eks_cluster_name
}
// TODO: filter for these subnet ids based on the vpc and subnet group info when needed rather than adding to tf output
output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}
output "nat_private_subnet_ids" {
  value = module.network.nat_private_subnet_ids
}
output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}
// TODO: append these values with jq rather than adding to tf output
output "subdomain_prefix" {
 value = var.subdomain_prefix
}
output "domain" {
 value = var.domain
}
output "num_availability_zones" {
 value = var.num_availability_zones
}
