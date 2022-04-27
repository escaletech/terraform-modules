variable "region" {
  type = string
}

variable "availability_zone_names" {
  type = list(string)
}

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

variable "environment" {
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

variable "namespaces_yml" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "eks_version" {
  type    = string
  default = "1.21"
}
