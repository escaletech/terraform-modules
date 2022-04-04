locals {
  engine         = "redis"
  engine_version = "5.0.6"
}

resource "aws_elasticache_replication_group" "main" {
  replication_group_id       = "${var.replication_group_id}-${var.environment}"
  description                = "${var.replication_group_id} ${var.environment} Redis Group"
  node_type                  = var.node_type
  port                       = 6379
  multi_az_enabled           = var.multi_az_enabled
  automatic_failover_enabled = true
  engine                     = local.engine
  engine_version             = local.engine_version
  security_group_ids         = var.security_group_ids

  subnet_group_name        = var.subnet_group_name
  maintenance_window       = "Mon:00:00-Mon:03:00"
  snapshot_window          = "03:00-06:00"
  snapshot_retention_limit = 1

  replicas_per_node_group = var.replicas
  num_node_groups         = var.nodes

  tags = var.tags
}
