data "aws_iam_policy_document" "s3_secure_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3_bucket.arn}/*"]
    effect    = "Allow"
  }
}