variable "name_prefix" {
  type = string
  default = null
}

variable "support_eks" {
  type = bool
  default = false
}

variable "vpc_cidr_block" {
  type = string
  default = null
}

variable "availability_zones" {
  type = list(string)
  default = null
}

variable "tls_subdomain" {
  type = string
  default = null
}
