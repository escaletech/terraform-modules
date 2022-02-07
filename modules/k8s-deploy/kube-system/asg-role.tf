data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "default" {
  name = var.cluster-name
}

locals {
  partition    = data.aws_partition.current.id
  account_id   = data.aws_caller_identity.current.account_id
  issuer_url   = data.aws_eks_cluster.default.identity[0].oidc[0].issuer
  url_stripped = replace(local.issuer_url, "https://", "")
  arn          = "arn:${local.partition}:iam::${local.account_id}:oidc-provider/${local.url_stripped}"
}

data "aws_iam_policy_document" "ns_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(local.issuer_url, "https://", "")}:sub"
      values   = [join(":", ["system", "serviceaccount", "kube-system", "cluster-autoscaler"])]
    }

    principals {
      identifiers = [local.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "kube-system" {
  assume_role_policy = data.aws_iam_policy_document.ns_assume_role_policy.json
  name               = "kube-system"
}
