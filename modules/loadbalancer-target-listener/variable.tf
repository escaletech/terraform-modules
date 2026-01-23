variable "vpc_id" {
  type = string
}

variable "target_name" {
  type        = string
}

variable "target_type" {
  type        = string
  default     = "ip"
}

variable "target_port" {
  type        = number
}

variable "target_protocol" {
  type        = string
  default     = "http"
}

variable "health_path" {
  type        = string
  default     = "/"
}

variable "health_statuscode" {
  type        = string
  default     = "200"
}

variable "listener_arn" {
    type = string
}

variable "host_header" {
    type    = list(string)
    default = []
}

variable "source_ip" {
    type    = list(string)
    default = []
}

variable "path_pattern" {
    type    = list(string)
    default = []
}

variable "ip" {
  type    = string
  default = ""
}