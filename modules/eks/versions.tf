terraform {
  required_providers {
    # Floor introduced by resolve_conflicts_on_create/on_update (provider >= 5.0).
    # Range open on purpose: consumers pin the effective version (v5 or v6).
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
}
