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
output "db_url" {
  value = module.rds.instance_address
}
output "domain" {
  value = module.networks.domain
}
output "eks_endpoint" {
  value = module.eks.endpoint
}
output "kubeconfig_certificate_authority_data" {
  value = module.eks.kubeconfig_certificate_authority_data
}
