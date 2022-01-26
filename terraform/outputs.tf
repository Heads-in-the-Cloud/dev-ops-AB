output "vpc_id" {
  value = module.networks.vpc_id
}
output "private_subnets" {
  value = module.networks.private_subnet_ids
}
output "public_subnets" {
  value = module.networks.public_subnet_ids
}
output "alb_id" {
  value = module.networks.alb_id
}
output "domain" {
  value = module.networks.domain
}
