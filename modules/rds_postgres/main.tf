locals {
  subnet_group_name     = "default-vpc-public"
  engine                = "postgres"
  engine_version        = "11.6"
  storage_encrypted     = false
  max_allocated_storage = 1000
}

resource "aws_db_instance" "default" {
  identifier            = "${var.identifier}-${var.environment}"
  engine                = local.engine
  engine_version        = local.engine_version
  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = local.max_allocated_storage
  storage_encrypted     = local.storage_encrypted

  username = "postgres"
  password = aws_secretsmanager_secret_version.dbpass.secret_string
  port     = "5432"

  availability_zone         = var.availability_zone
  maintenance_window        = "Mon:00:00-Mon:03:00"
  backup_window             = "03:00-06:00"
  final_snapshot_identifier = var.final_snapshot_identifier

  backup_retention_period = 1

  tags                            = var.tags
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  db_subnet_group_name = local.subnet_group_name
  publicly_accessible  = true

  deletion_protection = false
}
