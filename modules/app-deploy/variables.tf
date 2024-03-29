variable "app-name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "host" {
  type    = string
  default = null
}

variable "hosts" {
  type    = list(string)
  default = null
}

variable "host-private" {
  type    = string
  default = null
}

variable "port" {
  type    = number
  default = 3000
}

variable "path" {
  type    = string
  default = "/"
}

variable "replicas" {
  type    = number
  default = 2
}

variable "image-tag" {
  type    = string
  default = "latest"
}

variable "keel-interval" {
  description = "keel poll interval in minutes"
  type        = number
  default     = 1
}

variable "secrets" {
  type    = list(string)
  default = null
}

variable "tags" {
  type = map(string)
}

variable "environments" {
  type = list(object({
    name  = string
    value = string
  }))
  default = null
}

variable "ingress-annotations" {
  type    = map(string)
  default = null
}

variable "liveness" {
  type = object({
    initial_delay_seconds = number
    period_seconds        = number
  })
  default = null
}

variable "resources" {
  type = object({
    requests = object({
      memory = string
      cpu    = string
    })
    limits = object({
      memory = string
      cpu    = string
    })
  })
  default = null
}

variable "logger" {
  type    = string
  default = ""
}

variable "ingress-class-name" {
  type    = string
  default = "nginx"
}

variable "ingress-class-name-private" {
  type    = string
  default = "nginx"
}

variable "tolerations" {
  type = list(object({
    effect   = string
    key      = string
    operator = string
  }))
  default = null
}

variable "node-affinity" {
  type    = any
  default = {}
}

variable "pod-affinity" {
  type    = any
  default = {}
}

variable "pod-anti-affinity" {
  type    = any
  default = {}
}

variable "image-fulladdress" {
  type    = string
  default = null
}
