variable "name_prefix" {
  type = string
  default = null
}

variable "allocated_storage" {
  type = number
  default = null
}

variable "instance_class" {
  type = string
  default = null
}

variable "name" {
  type = string
  default = null
}

variable "port" {
  type = number
  default = null
}

variable "engine_version" {
  type = string
  default = null
}

variable "engine" {
  type = string
  default = null
}

variable "vpc" {
  type = object({
    id = string
    cidr_block = string
  })
  default = null
}

variable "subnet_ids" {
  type = list(string)
  default = null
}

variable "root_username" {
  type = string
  default = null
}

variable "root_password" {
  type = string
  default = null
  sensitive = true
}
