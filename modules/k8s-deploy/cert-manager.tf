module "cert_manager" {
  source                                 = "terraform-iaac/cert-manager/kubernetes"
  version                                = "2.4.2"
  cluster_issuer_email                   = "devadmin@escale.com.br"
  create_namespace                       = true
  cluster_issuer_name                    = "letsencrypt-prod"
  cluster_issuer_private_key_secret_name = "letsencrypt-prod-private-key"
}
