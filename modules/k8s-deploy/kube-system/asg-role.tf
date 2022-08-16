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
