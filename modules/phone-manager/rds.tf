data "aws_security_groups" "rds-sg" {
  filter {
    name   = "tag:Name"
    values = [var.rds_security_group]
  }
}
module "escale-rds" {
  source                 = "../escale-rds"
  identifier             = var.rds_identifier != null ? var.rds_identifier : join("-", [var.app_name, var.environment])
  username               = "root"
  rds_tags               = var.tags
  engine                 = "mysql"
  engine_version         = var.rds_engine_version
  parameter_group        = "mysqlphonemanager"
  instance_class         = var.rds_instance_class
  subnet_group           = var.rds_subnet_group
  publicly_accessible    = "false"
  vpc_security_group_ids = data.aws_security_groups.rds-sg.ids
  app_name               = var.app_name
  storage_encrypted      = var.rds_storage_encrypted
}
