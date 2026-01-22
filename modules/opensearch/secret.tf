resource "aws_secretsmanager_secret" "dbpass" {
  name = "escale/${var.name}/production/master-password"

  tags = var.tags
}

resource "random_password" "password" {
  length  = 16
  special = true
}

resource "aws_secretsmanager_secret_version" "dbpass" {
  secret_id      = aws_secretsmanager_secret.dbpass.id
  secret_string  = random_password.password.result
  version_stages = ["AWSCURRENT"]
}