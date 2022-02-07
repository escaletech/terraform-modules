variable "name" {
  description = "Topic name."
  type        = string
}

variable "environment" {
  description = "Type of environment where the queue will be running."
  type        = string
}

variable "role_name" {
  description = "Role name"
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

variable "topic_subscriptions" {
  type = map(object({
    protocol = string
    endpoint = string
  }))
  default = {}
}
