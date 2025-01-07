data "aws_iam_policy_document" "s3_secure_policy" {
  statement {
    actions   = var.s3_policy_document.statement[*].actions
    resources = var.s3_policy_document.statement[*].resources
    effect    = var.s3_policy_document.statement[*].effect
  }
}