output "vpc_id" {
  value = module.networks.vpc_id
}
output "private_subnets" {
  value = module.networks.subnet_ids.private
}
output "public_subnets" {
  value = module.networks.subnet_ids.public
}
output "alb_id" {
  value = module.networks.alb_id
}
output "domain" {
  value = module.networks.domain
}
output "db_subnet_group_name" {
  value = module.rds.subnet_group_name
}
output "db_security_group_id" {
  value = module.rds.security_group_id
}
