data "aws_iam_policy_document" "s3_secure_policy" {
  statement {
    actions   = var.s3_policy_document.statement[0].actions
    resources = var.s3_policy_document.statement[0].resources
    effect    = var.s3_policy_document.statement[0].effect
  }
}