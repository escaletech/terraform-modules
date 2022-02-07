variable "cluster-name" {
  type = string
}

variable "namespaces" {
  type    = list(string)
  default = []
}

variable "cluster-role-nodes" {
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
  type    = list(string)
}
