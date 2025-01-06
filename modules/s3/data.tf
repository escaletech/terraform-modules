data "aws_iam_policy_document" "s3_secure_policy" {
  for_each = { for idx, statement in var.s3_policy_document.statement : idx => statement }

  statement {
    actions   = each.value.actions
    resources = each.value.resources
    effect    = each.value.effect
  }
}