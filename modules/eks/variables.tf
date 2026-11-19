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

variable "endpoint_private_access" {
  description = "Whether the Kubernetes API endpoint is reachable from inside the VPC."
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Whether the Kubernetes API endpoint is reachable from the internet. When true, endpoint_public_access_cidrs limits who can reach it."
  type        = bool
  default     = true
}

variable "endpoint_public_access_cidrs" {
  description = "CIDRs allowed to reach the public Kubernetes API endpoint (CI, VPN, operators). Required; use [] only with endpoint_public_access = false. 0.0.0.0/0 is rejected (SD-3615)."
  type        = list(string)

  validation {
    condition     = !contains(var.endpoint_public_access_cidrs, "0.0.0.0/0")
    error_message = "endpoint_public_access_cidrs must not contain 0.0.0.0/0. List the CI, VPN and operator CIDRs, or set endpoint_public_access = false."
  }

  validation {
    condition     = length(var.endpoint_public_access_cidrs) > 0 || !var.endpoint_public_access
    error_message = "Informe ao menos um CIDR em endpoint_public_access_cidrs ou defina endpoint_public_access = false."
  }
}
