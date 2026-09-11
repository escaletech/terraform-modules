locals {
  required_tags = {
    environment = var.environment
    partner     = var.partner
    operation   = var.operation
    team        = var.team
    managed-by  = "terraform"
    repository  = var.repository
  }

  optional_tags = { for k, v in {
    criticality         = var.criticality
    data-classification = var.data_classification
    vertical            = var.vertical
    product             = var.product
    cost-center         = var.cost_center
    auto-stop           = var.auto_stop
    backup              = var.backup
  } : k => v if v != null }
}

output "tags" {
  description = "Map de tags para aplicar em todos os recursos do stack via default_tags ou merge()."
  value       = merge(local.required_tags, local.optional_tags, var.extra_tags)
}
