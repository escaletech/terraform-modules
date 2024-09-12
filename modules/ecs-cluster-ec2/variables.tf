variable "cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type for the ECS cluster"
  type        = string
}

variable "desired_capacity" {
  description = "The desired number of instances in the Auto Scaling group"
  type        = number
}

variable "max_size" {
  description = "The maximum number of instances in the Auto Scaling group"
  type        = number
}

variable "min_size" {
  description = "The minimum number of instances in the Auto Scaling group"
  type        = number
}

variable "key_name" {
  description = "The key name to use for the EC2 instances"
  type        = string
}

variable "subnet_ids" {
  description = "The subnet IDs where the ECS cluster will be deployed"
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
}

variable "enable_container_insights" {
  description = "Habilitar ou desabilitar o Container Insights"
  type        = string
  default     = "disabled"
}

variable "security_groups" {
  description = "value of security groups"
  type        = list(string)
}