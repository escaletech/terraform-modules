variable "replication_group_id" {
  description = "The replication group identifier."
  type        = string
}
variable "subnet_group_name" {
  description = "The name of the cache subnet group to be used for the replication group."
  type        = string
}
variable "security_group_ids" {
  description = "One or more Amazon VPC security groups associated with this replication group. Use this parameter only when you are creating a replication group in an Amazon Virtual Private Cloud."
  type        = list(string)
  default     = null
}
variable "environment" {
  description = "A mapping of tags to assign to all resources"
  type        = string
}
variable "node_type" {
  description = "The instance class to be used."
  type        = string
}
variable "replicas" {
  description = "Specify the number of replica nodes in each node group. Valid values are 0 to 5. Changing this number will trigger an online resizing operation before other settings modifications."
  type        = string
}
variable "nodes" {
  description = "Specify the number of node groups (shards) for this Redis replication group. Changing this number will trigger an online resizing operation before other settings modifications."
  type        = string
}
variable "multi_az_enabled" {
  description = "Specifies whether to enable Multi-AZ Support for the replication group."
  type        = string
  default     = null
}
variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
}
