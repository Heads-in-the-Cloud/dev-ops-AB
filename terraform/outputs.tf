output "vpc_id" {
  value = module.network.vpc_id
}
output "private_subnets" {
  value = module.network.subnet_ids.private
}
output "public_subnets" {
  value = module.network.subnet_ids.public
}
output "alb_sec_group_id" {
  value = module.network.alb_sec_group_id
}
output "db_url" {
  value = module.rds.instance_address
}
output "alb_id" {
  value = module.network.alb_id
}
output "domain" {
  value = module.network.domain
}
#output "eks_endpoint" {
#  value = module.eks.endpoint
#}
#output "kubeconfig_certificate_authority_data" {
#  value = module.eks.kubeconfig_certificate_authority_data
#  sensitive = true
#}
