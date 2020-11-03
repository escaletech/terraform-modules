# Database host
variable "db_host" { type = "string" }

# Database name to be created
variable "db_name" { type = "string" }

# master username with database/user creation permission
variable "db_master" { type = "string" }

# master password for user with database/user creation permission
variable "db_master_password" { type = "string" }

# New user to be created
variable "db_username" { type = "string" }

# Password for new user to be created
variable "db_password" { type = "string" }
