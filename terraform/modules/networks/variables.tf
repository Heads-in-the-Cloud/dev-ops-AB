variable "subnet_cidr_blocks" {
  type = object({
      private = list(string)
      nat_private = list(string)
      public = list(string)
  })
  default = null
}

variable "vpc_cidr_block" {
  type = string
  default = null
}

variable "ig_rt_cidr_block" {
  type = string
  default = null
}

variable "project_id" {
  type = string
  default = null
}
