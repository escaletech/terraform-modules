variable "app_name" {
  description = "The name of the AppConfig application."
  type        = string
}

variable "app_description" {
  description = "The description of the AppConfig application."
  type        = string
  default     = null
}

variable "env_name" {
  description = "The name of the AppConfig environment."
  type        = string
}

variable "env_description" {
  description = "The description of the AppConfig environment."
  type        = string
  default     = null
}

variable "profile_name" {
  description = "The name of the AppConfig configuration profile."
  type        = string
  default     = "env"
}

variable "deployment_strategy_name" {
  description = "The name for the deployment strategy."
  type        = string
  default     = "Immediate"
}

variable "deployment_strategy_description" {
  description = "The description for the deployment strategy."
  type        = string
  default     = "Immediate deployment"
}

variable "deployment_duration_in_minutes" {
  description = "The deployment duration in minutes."
  type        = number
  default     = 0
}

variable "final_bake_time_in_minutes" {
  description = "The final bake time in minutes."
  type        = number
  default     = 0
}

variable "growth_factor" {
  description = "The growth factor for the deployment strategy."
  type        = number
  default     = 100
}

variable "growth_type" {
  description = "The growth type for the deployment strategy."
  type        = string
  default     = "LINEAR"
}

variable "replicate_to" {
  description = "Where to replicate the deployment strategy."
  type        = string
  default     = "NONE"
}

variable "tags" {
  description = "A map of tags to apply to the resources."
  type        = map(string)
  default     = {}
}

variable "configuration_content" {
  description = "The content of the configuration version. If null, no configuration version is created."
  type        = string
  default     = null
}

variable "configuration_content_type" {
  description = "The content type of the configuration version."
  type        = string
  default     = "application/json"
}

variable "configuration_version_description" {
  description = "The description of the configuration version."
  type        = string
  default     = null
}
