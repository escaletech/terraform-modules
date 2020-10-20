resource "aws_secretsmanager_secret" "dbpass" {
  name = "id-verify/db-master-password/${var.environment}"
  tags = var.tags
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%-^!#"
}

resource "aws_secretsmanager_secret_version" "dbpass" {
  secret_id     = aws_secretsmanager_secret.dbpass.name
  secret_string = random_password.password.result
}
