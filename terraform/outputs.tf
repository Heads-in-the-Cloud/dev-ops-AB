output "vpc_id" {
  value = module.networks.vpc_id
}
output "private_subnets" {
  value = module.networks.private_subnets
}
output "public_subnets" {
  value = module.networks.public_subnets
}
output "db_url" {
  value = module.rds.instance_address
}
output "alb_id" {
  value = module.networks.alb_id
}
output "domain" {
  value = module.networks.domain
}
