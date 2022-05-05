variable "region" {
  type    = string
  default = null
}

variable "project_id" {
  type    = string
  default = ""
}

variable "s3_bucket" {
  type    = string
  default = ""
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
  default = ""
}

variable "domain" {
  type    = string
  default = ""
}
