variable "allocated_storage" {
  description = "Pre-allocated storage in MB"
  type        = number
  default     = 100
}

variable "availability_zone" {
  description = "Availability zone"
  type        = string
  default     = "us-east-1c"
}

variable "identifier" {
  description = "RDS identifier"
  type        = string
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "final_snapshot_identifier" {
  description = "Final snapshot identifier (for when this database is deleted)"
  type        = string
}

variable "tags" {
  description = "Map of tags to identify this resource on AWS"
  type        = map(any)
  default = {
    Name        = "add-application-name"
    Owner       = "add-application-owner"
    Environment = "add-environment"
    Repository  = "add-github-repository"
  }
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "publicly_accessible" {
  description = "Whether the instance gets a public IP. Keep false and reach the database through the VPC/VPN; set true only with an explicit, documented need (SD-3455)."
  type        = bool
  default     = false
}
