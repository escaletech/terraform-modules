variable "environment" {
  type        = string
  description = "Environment where the resource will be deployed, e.g. 'production', 'staging', 'development', 'beta', 'test'"
}

variable "region" {
  type        = string
  description = "The name of the AWS region"
}

variable "short_desc" {
  type        = string
  description = "A short description for this module"
  default     = "The PostgreSQL RDS instance for all dev apps"
}

variable "sec_group_name" {
  type        = string
  description = "The name of the security group to associate with this instance"
  default     = "default"
}

variable "password" {
  type        = string
  description = "The root password for the RDS instance"
}

variable "publicly_accessible" {
  type        = string
  description = "If the RDS instance should be exposed to public subnets"
  default     = false
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default     = {}
}