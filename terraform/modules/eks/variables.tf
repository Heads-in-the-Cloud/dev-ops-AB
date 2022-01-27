variable "project_id" {
  type    = string
  default = null
}

variable "environment" {
  type    = string
  default = null
}

variable "subnet_ids" {
  type    = list(string)
  default = null
}
