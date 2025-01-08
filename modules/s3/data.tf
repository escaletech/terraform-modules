data "aws_iam_policy_document" "s3_secure_policy" {
  statement {
    sid       = var.s3_policy_document.statement[0].sid
    actions   = var.s3_policy_document.statement[0].actions
    resources = var.s3_policy_document.statement[0].resources
    effect    = var.s3_policy_document.statement[0].effect
    principals {
      type        = var.s3_policy_document.statement[0].principals.type
      identifiers = var.s3_policy_document.statement[0].principals.identifiers
    }
  }
}