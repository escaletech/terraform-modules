# Pre-allocated storage in MB
variable "allocated_storage" {
  type    = number
  default = 100
}

# Availability zone
variable "availability_zone" {
  type    = string
  default = "us-east-1c"
}

# RDS identifier
variable "identifier" {
  type = string
}

# RDS instance class
variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

# Final snapshot identifier (for when this database is deleted)
variable "final_snapshot_identifier" {
  type = string
}

# Map of tags to identify this resource on AWS
variable "tags" {
  type = map
  default = {
    Name        = "add-application-name"
    Owner       = "add-application-owner"
    Environment = "add-environment"
    Repository  = "add-github-repository"
  }
}

# Deployment environment
variable "environment" {
  type = string
}
