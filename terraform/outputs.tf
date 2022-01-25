output "domain" {
  value = module.networks.domain
}
output "vpc_id" {
  value = module.networks.vpc_id
}
output "db_url" {
  value = module.rds.instance_address
}
output "alb_id" {
  value = module.networks.alb_id
}
