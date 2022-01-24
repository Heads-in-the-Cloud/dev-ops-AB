variable "region" {
  type        = string
  default     = null
  description = "region"
}

variable "project_id" {
  type        = string
  default     = null
  description = "project identifier to suffix all names with"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "dev, staging, or prod"
}

variable "public_ssh_key" {
  type        = string
  default     = null
  description = "SSH key used for bastion hosts"
}
