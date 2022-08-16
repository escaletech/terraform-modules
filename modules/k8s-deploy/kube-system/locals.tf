locals {
  partition    = data.aws_partition.current.id
  account_id   = data.aws_caller_identity.current.account_id
  issuer_url   = data.aws_eks_cluster.default.identity[0].oidc[0].issuer
  url_stripped = replace(local.issuer_url, "https://", "")
  arn          = "arn:${local.partition}:iam::${local.account_id}:oidc-provider/${local.url_stripped}"
}
