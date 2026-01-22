module "backup_opensearch" {
  count              = var.enable_s3_backup ? 1 : 0
  source             = "github.com/escaletech/terraform-modules/modules/s3"
  bucket_name        = var.bucket_name
  website_static_acl = false

  depends_on = [
    aws_iam_policy.S3_OpenSearch_Backup_Policy,
    aws_iam_role.S3_OpenSearch_Backup
  ]

  s3_policy_document = {
    statement = [
      {
        sid = "PublicReadForGetBucketObjects"
        actions = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        resources = [
          "arn:aws:s3:::${var.bucket_name}/*",
          "arn:aws:s3:::${var.bucket_name}"
        ]
        effect = "Allow"
        principals = {
          type        = "AWS"
          identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.S3_OpenSearch_Backup.name}"]
        }
      }
    ]
  }
}

# ... (adicione os IAM resources para S3 com count = var.enable_s3_backup ? 1 : 0)