locals {
  required_tags = {
    Environment = var.environment
    Partner     = var.partner
    Operation   = var.operation
    Owner       = var.owner
    ManagedBy   = "Terraform"
    Repository  = var.repository
  }

  optional_tags = { for k, v in {
    Criticality        = var.criticality
    DataClassification = var.data_classification
    Vertical           = var.vertical
    Product            = var.product
    CostCenter         = var.cost_center
    AutoStop           = var.auto_stop
    Backup             = var.backup
  } : k => v if v != null }
}

output "tags" {
  description = "Map de tags em PascalCase para aplicar em todos os recursos do stack via default_tags ou merge()."
  value       = merge(local.required_tags, local.optional_tags, var.extra_tags)
}
