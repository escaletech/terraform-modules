data "aws_secretsmanager_secret" "api-key-datadog" {
  count = var.datadog-enabled != true ? 0 : 1
  name  = var.datadog-api-secrets-manager
}

data "aws_secretsmanager_secret_version" "api-key-datadog-version" {
  count     = var.datadog-enabled != true ? 0 : 1
  secret_id = data.aws_secretsmanager_secret.api-key-datadog[count.index].id
}
