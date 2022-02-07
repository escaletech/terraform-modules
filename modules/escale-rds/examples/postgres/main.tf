module "escale-rds" {
  source          = "../../"
  app_name        = "example"
  password        = var.password
  username        = "root"
  rds_tags        = {}
  engine          = "postgres"
  engine_version  = "10.13"
  parameter_group = "default.postgres10"
  instance_class  = "db.t2.micro"
  subnet_group    = "default"
  environment     = "staging"
}
