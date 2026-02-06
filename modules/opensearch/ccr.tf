# =============================================
# Cross-Cluster Replication (CCR)
# =============================================

locals {
  ccr_enabled          = var.ccr != null && var.ccr.remote_domain != null
  ccr_accept_inbound   = var.ccr != null && var.ccr.accept_inbound_connection_id != ""
}

resource "aws_opensearch_outbound_connection" "ccr" {
  count            = local.ccr_enabled ? 1 : 0
  connection_alias = var.ccr.connection_alias != "" ? var.ccr.connection_alias : "${var.name}-to-${var.ccr.remote_domain.domain_name}"
  connection_mode  = var.ccr.connection_mode

  local_domain_info {
    domain_name = aws_opensearch_domain.opensearch.domain_name
    owner_id    = data.aws_caller_identity.current.account_id
    region      = var.region
  }

  remote_domain_info {
    domain_name = var.ccr.remote_domain.domain_name
    owner_id    = var.ccr.remote_domain.owner_id
    region      = var.ccr.remote_domain.region
  }
}

resource "aws_opensearch_inbound_connection_accepter" "ccr" {
  count         = local.ccr_accept_inbound ? 1 : 0
  connection_id = var.ccr.accept_inbound_connection_id
}
