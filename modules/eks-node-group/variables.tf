variable "eks_cluster_name" {
  type        = string
  description = "The name of the EKS cluster"
}

variable "subnet_ids" {
  type        = list(string)
  description = "The IDs of the public subnets"
}

variable "node_group_name" {
  type        = string
  description = "The name of the node group"
}

variable "node_role_arn" {
  type        = string
  description = "The ARN of the node role"
}

variable "node_instance_types" {
  type        = list(string)
  description = "The instance types to use for the node group"
  default     = []
}

variable "node_desired_state" {
  type        = number
  description = "The desired number of nodes in the node group"
  default     = 1
}

variable "node_min_size" {
  type        = number
  description = "The minimum number of nodes in the node group"
  default     = 1
}

variable "node_max_size" {
  type        = number
  description = "The maximum number of nodes in the node group"
  default     = 3
}

variable "tags" {
  type        = map(string)
  description = "The tags to apply to the node group"
  default     = {}
}

variable "enable_taint" {
  type        = bool
  default     = false
}
