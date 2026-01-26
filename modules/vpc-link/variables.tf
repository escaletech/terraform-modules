variable "name" {
  description = "Name for the API Gateway VPC Link (REST API / v1)."
  type        = string
}

variable "description" {
  description = "Optional description for the VPC Link."
  type        = string
  default     = null
}

variable "target_arns" {
  description = "List of Network Load Balancer ARNs to attach to the VPC Link."
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to the VPC Link."
  type        = map(string)
  default     = {}
}
