resource "aws_db_instance" "db" {
  allocated_storage               = var.replicate_source_db == null ? var.allocated_storage : null
  identifier                      = var.identifier
  storage_type                    = var.storage_type
  engine                          = var.replicate_source_db == null ? var.engine : null
  engine_version                  = var.replicate_source_db == null ? var.engine_version : null
  instance_class                  = var.instance_class
  username                        = var.replicate_source_db == null ? var.username : null
  password                        = var.replicate_source_db == null ? aws_secretsmanager_secret_version.dbpass.secret_string : null
  parameter_group_name            = var.parameter_group
  option_group_name               = var.option_group
  skip_final_snapshot             = true
  publicly_accessible             = var.publicly_accessible
  db_subnet_group_name            = var.subnet_group
  final_snapshot_identifier       = "Ignore"
  tags                            = var.rds_tags
  deletion_protection             = var.deletion_protection
  auto_minor_version_upgrade      = true
  apply_immediately               = true
  maintenance_window              = var.maintenance_window
  backup_retention_period         = var.backup_retention_period
  backup_window                   = var.backup_window
  copy_tags_to_snapshot           = var.copy_tags_to_snapshot
  storage_encrypted               = var.storage_encrypted
  vpc_security_group_ids          = var.vpc_security_group_ids
  snapshot_identifier             = var.snapshot_identifier
  replicate_source_db             = var.replicate_source_db
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  lifecycle {
    ignore_changes = [engine_version]
  }
}
