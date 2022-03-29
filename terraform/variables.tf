variable "region" {
  type    = string
  default = null
}

variable "project_id" {
  type        = string
  default     = null
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "dev, staging, or prod"
}

variable "vpc_cidr_block" {
  type    = string
  default = null
}

variable "num_availability_zones" {
  type    = number
  default = null
}

variable "subdomain_prefix" {
  type    = string
  default = null
}

variable "domain" {
  type    = string
  default = null
}
