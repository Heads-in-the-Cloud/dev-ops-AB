variable "project_id" {
  type = string
  default = null
}
variable "vpc_id" {
  type = string
  default = null
}
variable "use_fargate" {
  type = bool
  default = true
}
variable "node_instance_type" {
  type = string
  default = null
}
variable "subnet_ids" {
  type = list(string)
  default = null
}
