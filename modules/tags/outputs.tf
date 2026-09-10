locals {
  required_tags = {
    env              = var.env
    business-partner = var.business_partner
    operation        = var.operation
    vertical         = var.vertical
    team             = var.team
    managed-by       = "terraform"
    repository       = var.repository
  }

  optional_tags = { for k, v in {
    product             = var.product
    cost-center         = var.cost_center
    criticality         = var.criticality
    data-scope          = var.data_scope
    auto-stop           = var.auto_stop
    backup              = var.backup
    data-classification = var.data_classification
  } : k => v if v != null }
}

output "tags" {
  description = "Map de tags para aplicar em todos os recursos do stack via default_tags ou merge()."
  value       = merge(local.required_tags, local.optional_tags, var.extra_tags)
}
