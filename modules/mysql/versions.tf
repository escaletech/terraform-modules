terraform {
  required_providers {
    mysql = {
      source  = "terraform-providers/mysql"
      version = "~> 1.6"
    }
  }
  required_version = ">= 0.13"
}
