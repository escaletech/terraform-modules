variable "vpc_name" {
  description = "The tag Name for the VPC resource"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
}

variable "name" {
  description = "The broker name"
  type        = string
}

variable "instance_type" {
  description = "The broker instance type."
  type        = string
  default     = "mq.t3.micro"
}

variable "subnets" {
  description = <<EOD
    A map of subnets where the key is availability zone and the value the subnet name.
    Ex: {
      "us-east-1a" = "subnet-a"
      "us-east-1b" = "subnet-b"
    }
EOD
  type        = map(any)
}

variable "deployment_mode" {
  description = "Deployment mode of the broker (SINGLE_INSTANCE or CLUSTER_MULTI_AZ)"
  type        = string
  default     = "SINGLE_INSTANCE"
}

variable "username" {
  description = "Username of the user"
  type        = string
}

variable "password" {
  description = "Password of the user. It must be 12 to 250 characters long, at least 4 unique characters, and must not contain commas."
  type        = string
}

variable "publicly_accessible" {
  description = "Whether to enable connections from applications outside of the VPC that hosts the broker's subnets"
  type        = bool
  default     = false
}
