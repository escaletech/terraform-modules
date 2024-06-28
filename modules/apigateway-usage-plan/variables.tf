variable "quota_settings" {
  description = "quota settings for usage plan"
  type        = list(object({
    limit  = number
    period = string
  }))
  default = [ {
    limit  = 10000
    period = "DAY"
  } ]
}

variable "throttle_settings" {
  description = "Throttle settings for the usage plan"
  type = list(object({
    rate_limit  = number
    burst_limit = number
  }))
  default = []
}

variable "api_stage" {
  description = "API stage for usage plan"
  type        = list(object({
    api_id = string
    stage  = string
  }))
  default = []
}

variable "partner" {
  description = "partners to usage plan"
  type        = string
}

variable "key_enabled" {
  description = "enable api key"
  type        = bool
  default     = true
}

variable "description" {
  description = "description of usage plan"
  type        = string
}