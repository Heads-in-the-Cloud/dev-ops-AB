variable "project_id" {
  type    = string
  default = null
}

variable "environment" {
  type    = string
  default = null
}

variable "vpc_id" {
  type    = string
  default = null
}

variable "subnet_ids" {
  type    = object({
    eks = list(string)
    eks_node_group = list(string)
  })
  default = null
}
