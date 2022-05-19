variable "host" {
  type = string
}

variable "vpc_ids" {
  type = list(string)
}

variable "lb_private_tag" {
  type = map(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}
