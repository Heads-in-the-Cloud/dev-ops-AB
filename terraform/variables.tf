variable "region" {
  type    = string
  default = null
}

variable "s3_bucket" {
  type    = string
  default = null
}

variable "name_prefix" {
  type        = string
  default     = null
  description = "identifier to prefix all names with"
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
