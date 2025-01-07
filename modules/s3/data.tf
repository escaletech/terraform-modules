# data "aws_iam_policy_document" "s3_secure_policy" {
#   statement {
#     actions   = var.s3_policy_document.statement[*].actions
#     resources = var.s3_policy_document.statement[*].resources
#     effect    = var.s3_policy_document.statement[*].effect
#   }
# }

data "aws_iam_policy_document" "s3_secure_policy" {
  statement {
    actions   = flatten([for s in var.s3_policy_document.statement : s.actions])
    resources = flatten([for s in var.s3_policy_document.statement : s.resources])
    effect    = join(",", [for s in var.s3_policy_document.statement : s.effect])
  }
}