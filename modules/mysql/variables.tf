variable "db_host" {
  description = "Database host"
  type        = "string"
}

variable "db_name" {
  description = "Database name to be created"
  type        = "string"
}

variable "db_master" {
  description = "Master username with database/user creation permission"
  type        = "string"
}

variable "db_master_password" {
  description = "Master password for user with database/user creation permission"
  type        = "string"
}

variable "db_username" {
  description = "New user to be created"
  type        = "string"
}

variable "db_password" {
  description = "Password for new user to be created"
  type        = "string"
}
