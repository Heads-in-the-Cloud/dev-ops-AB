variable "project_id" {
  type = string
  default = null
}

variable "subnet_ids" {
  type = list(string)
  default = null
}

variable "vpc" {
  type = object({
    id = string
    cidr_block = string
  })
  default = null
}
