variable "region" {
  type        = string
  description = "AWS region to deploy the OpenSearch domain"
}

variable "vpc" {
  type        = string
  description = "VPC name tag to filter"
}

variable "name" {
  type        = string
  description = "OpenSearch domain name"
}

variable "bucket_name" {
  type        = string
  description = "S3 bucket name for backups"
}

variable "instance_type" {
  type        = string
  description = "OpenSearch instance type"
}

variable "subnet" {
  type        = list(string)
  description = "Subnet name tags for private subnets"
}

variable "volume_size" {
  type        = number
  description = "EBS volume size in GB"
}

variable "instance_count" {
  type        = number
  description = "Number of instances"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags for resources"
}

variable "engine_version" {
  type        = string
  default     = "OpenSearch_2.15"
  description = "OpenSearch engine version"
}

variable "enable_alarms" {
  type        = bool
  default     = false
  description = "Enable CloudWatch alarms"
}

variable "enable_s3_backup" {
  type        = bool
  default     = false
  description = "Enable S3 backup bucket and policies"
}

variable "enable_event_bridge" {
  type        = bool
  default     = false
  description = "Enable EventBridge for autoscaling"
}

variable "ingress_cidrs" {
  type        = list(string)
  default     = ["172.26.0.0/16", "172.16.0.0/16", "10.212.0.0/16"]
  description = "CIDRs for ingress in security group"
}

variable "domain_name" {
  type        = string
  description = "OpenSearch domain name"
}