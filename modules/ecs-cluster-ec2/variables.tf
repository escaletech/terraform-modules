variable "cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type for the ECS cluster"
  type        = string
  default     = "t3.medium"
}

variable "desired_capacity" {
  description = "The desired number of instances in the Auto Scaling group"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "The maximum number of instances in the Auto Scaling group"
  type        = number
  default     = 5
}

variable "min_size" {
  description = "The minimum number of instances in the Auto Scaling group"
  type        = number
  default     = 1
}

variable "key_name" {
  description = "The key name to use for the EC2 instances"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the ECS cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "The subnet IDs where the ECS cluster will be deployed"
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}