variable "domain_front" {
  description = "This is the domain page to the front page of the phone manager instance to be created"
  type        = string
}

variable "domain_backend" {
  description = "This is the domain page to the backend of the phone manager instance to be created"
  type        = string
}

variable "dns_zone_name" {
  description = "This is the dns zone name related to domain_front and domain_backend."
  type        = string
}

variable "app_name" {
  description = "App name. Defaults to phone-manager."
  type        = string
  default     = "phone-manager"
}

variable "vpc_name" {
  description = "VPC Name where our instance will be created."
  type        = string
}

variable "subnets" {
  description = "Subnet list id for application load balancer. The first is where the EC2 instance is going to be created. We need a second one in a different availability zone for the load balancer."
  type        = list(string)
}

variable "ec2_security_group" {
  description = "Security group for EC2"
  type        = string
}

variable "rds_identifier" {
  description = "RDS instance name. Optional."
  type        = string
  default     = null
}

variable "rds_instance_class" {
  description = "Instance class type for RDS."
  type        = string
  default     = "db.t4g.medium"
}

variable "rds_engine_version" {
  description = "MySQL version to be created"
  type        = string
}

variable "rds_security_group" {
  description = "Security group for RDS"
  type        = string
}

variable "rds_subnet_group" {
  description = "Subnet group for RDS"
  type        = string
}

variable "rds_storage_encrypted" {
  description = "If the RDS data storage should be encrypted"
  type        = bool
  default     = false
}

variable "rds_snapshot_identifier" {
  description = "The snapshot identification"
  type        = string
  default     = null
}

variable "rds_deletion_protection" {
  description = "If the DB instance should have deletion protection enabled"
  type        = bool
  default     = true
}

variable "rds_allocated_storage" {
  description = "O armazenamento alocado em gibibytes"
  type        = number
  default     = 10
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Type of environment where the queue will be running."
  type        = string
}

variable "public_key" {
  description = "Key pair to be attached to the ec2 instance created."
  type        = map(any)
}

variable "ami" {
  description = "AMI for the instance to be created"
  type        = string
  default     = "ami-042e8287309f5df03"
}

variable "instance_type" {
  description = "Instance type for the EC2."
  type        = string
  default     = "t3a.medium"
}

variable "user_data" {
  description = "Script to be executed after instance creation."
  type        = string
}

variable "internal" {
  description = "If the load balancer is served internally on VPC or open"
  type        = bool
  default     = false
}

variable "lb_security_group" {
  description = "Security group used by load balancer"
  type        = string
}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_security_group" "sg" {
  filter {
    name   = "tag:Name"
    values = [var.ec2_security_group]
  }
}

data "aws_security_group" "sg-lb" {
  filter {
    name   = "tag:Name"
    values = [var.lb_security_group]
  }
}

variable "iam_instance_profile" {
  type    = string
  default = ""
}

variable "volume_size" {
  description = "root block device's volume size"
  type        = number
  default     = 8
}

variable "sg-name" {
  type    = string
  default = null
}

variable "aws_lb_dns" {
  type = string
}

variable "aws_lb_zone_id" {
  type = string
}

variable "aws_lb_listener_arn" {
  description = "listener arn"
  type        = string
}

variable "aws_lb_rule_priority" {
  description = "priority number"
  type        = number
}