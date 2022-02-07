variable "permission_set_name" {
  description = "Permission set name"
  type        = string
}

variable "attach_policies" {
  description = "List of existing policies to attach"
  type        = list(string)
  default     = []
}

variable "inline_policy" {
  description = "Json policy to attach"
  type        = string
  default     = null
}

variable "session_duration" {
  description = "Duration time as integer"
  type        = number
}
