variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "cluster-name" {
  type = string
}

variable "node-instance-type" {
  type = string
}

variable "asg-desired-capacity" {
  type    = number
  default = 2
}

variable "asg-max-size" {
  type    = number
  default = 2
}

variable "asg-min-size" {
  type    = number
  default = 1
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "eks_version" {
  type    = string
  default = "1.21"
}

variable "kube_proxy_version" {
  type    = string
  default = "v1.21.2-eksbuild.2"
}

variable "core_dns_version" {
  type    = string
  default = "v1.8.4-eksbuild.1"
}
