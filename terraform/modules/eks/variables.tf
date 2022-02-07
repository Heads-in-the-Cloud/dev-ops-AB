variable "project_id" {
  type = string
  default = null
}
variable "vpc_id" {
  type = string
  default = null
}
variable "node_instance_type" {
  type = string
  default = null
}
variable "cluster_subnet_ids" {
  type = list(string)
  default = null
}
variable "node_group_subnet_ids" {
  type = list(string)
  default = null
}
