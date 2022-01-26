variable "subnet_cidr_blocks" {
  type = object({
    private = list(string)
    public = list(string)
  })
}

variable "vpc_cidr_block" {
  type = string
  default = null
}

variable "rt_cidr_block" {
  type = string
  default = null
}

variable "project_id" {
  type = string
  default = null
}
