variable "namespaces" {
  type    = list(string)
  default = []
}

variable "namespaces-with-roles" {
  type    = list(string)
  default = []
}

variable "cluster-name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
