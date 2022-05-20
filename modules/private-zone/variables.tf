variable "host" {
  type = string
}

variable "vpc_ids" {
  type = list(string)
}

variable "lb_private_tag" {
  type = map(string)
}

variable "ingress-lb-record" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
