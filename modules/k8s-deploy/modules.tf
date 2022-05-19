module "kube-system" {
  source                      = "./kube-system"
  cluster-name                = var.cluster-name
  datadog-enabled             = var.datadog-enabled
  datadog-api-secrets-manager = var.datadog-api-secrets-manager
}
