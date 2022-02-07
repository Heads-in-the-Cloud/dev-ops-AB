output "vpc_id" {
  value = module.network.vpc_id
}
output "subnet_ids" {
  value = module.network.subnet_ids
}
output "alb_sec_group_id" {
  value = module.network.alb_sec_group_id
}
output "db_url" {
  value = module.rds.instance_address
}
output "alb_names" {
  value = module.network.alb_names
}
