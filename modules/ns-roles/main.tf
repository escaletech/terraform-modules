data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "main" {
  name = var.cluster-name
}

resource "kubernetes_namespace" "main" {
  for_each = toset(var.namespaces)
  metadata {
    name = each.value
  }
}

locals {
  partition    = data.aws_partition.current.id
  account_id   = data.aws_caller_identity.current.account_id
  issuer_url   = data.aws_eks_cluster.main.identity[0].oidc[0].issuer
  url_stripped = replace(local.issuer_url, "https://", "")
  arn          = "arn:${local.partition}:iam::${local.account_id}:oidc-provider/${local.url_stripped}"
}

data "aws_iam_policy_document" "ns_assume_role_policy" {
  for_each = toset(var.namespaces)
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(local.issuer_url, "https://", "")}:sub"
      values   = [join(":", ["system", "serviceaccount", each.value, "default"])]
    }

    principals {
      identifiers = [local.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "ns" {
  for_each           = toset(var.namespaces)
  assume_role_policy = data.aws_iam_policy_document.ns_assume_role_policy[each.value].json
  name               = each.value
  tags               = var.tags
}

resource "kubernetes_service_account" "sa" {
  for_each = toset(var.namespaces)
  metadata {
    name = "default"
    namespace = each.value
    annotations = { "eks.amazonaws.com/role-arn" = "arn:aws:iam::${local.account_id}:role/${each.value}" }
  }
}
