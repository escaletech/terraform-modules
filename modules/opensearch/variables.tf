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

variable "enable_s3_backup" {
  type        = bool
  default     = false
  description = "Enable S3 backup bucket and policies"
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

# =============================================
# Cross-Cluster Replication (CCR)
# =============================================

variable "ccr" {
  type = object({
    connection_alias             = optional(string, "")
    connection_mode              = optional(string, "DIRECT")
    remote_domain                = optional(object({
      domain_name = string
      region      = string
      owner_id    = string
    }))
    accept_inbound_connection_id = optional(string, "")
  })
  default     = null
  description = "Cross-Cluster Replication (CCR) configuration. Set to null to disable."
}