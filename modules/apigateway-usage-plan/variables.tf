variable "quota_settings" {
  description = "quota settings for usage plan"
  type        = list(object({
    limit  = number
    period = string
  }))
}

variable "throttle_settings" {
  description = "throttle settings for usage plan"
  type        = list(object({
    rate_limit  = number
    burst_limit = number
  }))
}

variable "api_stage" {
  description = "api stage to usage plan"
  type        = list(object({
    api_id = string
    stage  = string
  }))
}

variable "partners" {
  description = "partners to usage plan"
  type        = list(string)
}

variable "key_enabled" {
  description = "enable api key"
  type        = bool
  default     = true
}

variable "name" {
  description = "name of usage plan"
  type        = string
}

variable "description" {
  description = "description of usage plan"
  type        = string
}