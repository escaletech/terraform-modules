variable "password" {
  type        = string
  description = "The root password for the RDS instance"
  default     = null
}

variable "publicly_accessible" {
  type        = string
  description = "If the RDS instance should be exposed to public subnets. Defaults to false"
  default     = false
}

variable "rds_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to all resources"
  default     = {}
}

variable "username" {
  description = "The database owner user name"
  type        = string
  default     = null
}

variable "allocated_storage" {
  description = "The database size in Gb. Defaults to 10"
  type        = number
  default     = null
}

variable "engine" {
  description = "The RDS engine type (mysql/postgres)"
  type        = string
  default     = null
}

variable "engine_version" {
  description = "The RDS engine version"
  type        = string
  default     = null
}

variable "instance_class" {
  description = "The RDS instance class. Defaults to db.t2.small"
  type        = string
  default     = "db.t2.micro"
}

variable "parameter_group" {
  description = "The parameter group name to use"
  type        = string
  default     = null
}

variable "option_group" {
  description = "The option group name to use"
  type        = string
  default     = null
}

variable "maintenance_window" {
  description = "When a minor upgrade should be executed. Defaults to 'Wed:00:00-Wed:03:00'"
  type        = string
  default     = "Wed:00:00-Wed:03:00"
}

variable "subnet_group" {
  description = "The name of the subnet group to associate with the RDS instance"
  type        = string
  default     = null
}

variable "backup_retention_period" {
  description = "The days to retain backups for"
  type        = string
  default     = 5
}

variable "backup_window" {
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled"
  type        = string
  default     = "04:00-05:00"
}

variable "copy_tags_to_snapshot" {
  description = "Copy all Instance tags to snapshots"
  type        = bool
  default     = true
}

variable "storage_encrypted" {
  description = "If the RDS data storage should be encrypted"
  type        = bool
  default     = false
}

variable "skip_tag_name" {
  description = "Skips using the tag Name to search for the security group to associated with the RDS instance"
  type        = bool
  default     = false
}

variable "identifier" {
  description = "The RDS identifier. Defaults to 'none', and in this case the Project_name tag is used instead"
  type        = string
  default     = "none"
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate."
  type        = list(any)
  default     = null
}

variable "snapshot_identifier" {
  description = "THe snapshot identification"
  type        = string
  default     = null
}

variable "replicate_source_db" {
  description = "The source database"
  type        = string
  default     = null
}

variable "environment" {
  description = "Type of environment where the rds will be running."
  type        = string
}


variable "app_name" {
  description = "The application name"
  type        = string
}

variable "enabled_cloudwatch_logs_exports" {
  description = "Set of log types to enable for exporting to CloudWatch logs"
  type        = set(string)
  default     = null
}
