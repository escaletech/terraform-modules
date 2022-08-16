variable "cluster-name" {
  type = string
}

variable "namespaces" {
  type    = list(string)
  default = []
}

variable "namespaces-without-roles" {
  type    = list(string)
  default = []
}

variable "cluster-role-nodes" {
  type = string
}

variable "vpc-name" {
  type = string
}

variable "private-subnet-prefix" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "admin-sso-role" {
  type = string
}

variable "viewers-sso-role" {
  type = string
}

variable "developer-sso-role" {
  type = string
}

variable "iam-users" {
  type    = list(string)
  default = []
}

variable "datadog-enabled" {
  type = bool
}

variable "cluster-domain" {
  type = string
}

variable "nlb_subnets" {
  type = list(string)
}

variable "datadog-api-secrets-manager" {
  type = string
}

variable "ingress_class_is_default" {
  type    = bool
  default = true
}

variable "efs-enabled" {
  type    = bool
  default = false
}
