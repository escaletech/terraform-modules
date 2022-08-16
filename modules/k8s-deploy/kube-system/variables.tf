variable "cluster-name" {
  type = string
}

variable "datadog-enabled" {
  type = bool
}

variable "datadog-api-secrets-manager" {
  type = string
}

variable "efs-enabled" {
  type = bool
}
