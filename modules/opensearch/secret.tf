resource "aws_secretsmanager_secret" "dbpass" {
  name = "escale/saas-${var.name}/production/master-password"

  tags = var.tags
}

resource "random_password" "password" {
  length           = 16
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  special          = true
  override_special = "_%-^!#"
}

resource "aws_secretsmanager_secret_version" "dbpass" {
  secret_id      = aws_secretsmanager_secret.dbpass.id
  secret_string  = random_password.password.result
  version_stages = ["AWSCURRENT"]
}