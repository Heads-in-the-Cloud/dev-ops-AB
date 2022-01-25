output "domain" {
  value = module.networks.domain
}
output "vpc_id" {
  value = aws_vpc.default.id
}
output "db_url" {
  value = module.rds.instance_address
}
output "alb_id" {
  value = module.networks.alb_id
}
output "bastion_ip" {
  value = module.bastion.public_ipv4
}
