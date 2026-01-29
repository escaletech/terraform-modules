# =============================================
# Policies para S3 Backup (usado pelo módulo backup_opensearch)
# =============================================

resource "aws_iam_role" "S3_OpenSearch_Backup" {
  count = var.enable_s3_backup ? 1 : 0

  name = "S3_OpenSearch_SaaS_Backup_${var.region}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = { Service = "s3.amazonaws.com" }
        Effect    = "Allow"
        Sid       = ""
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_policy" "S3_OpenSearch_Backup_Policy" {
  count = var.enable_s3_backup ? 1 : 0

  name        = "S3_OpenSearch_SaaS_Backup_Policy_${var.region}"
  description = "Policy para permitir que o bucket S3 de backup do OpenSearch seja acessado"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_S3_OpenSearch_Backup_Policy" {
  count = var.enable_s3_backup ? 1 : 0

  policy_arn = aws_iam_policy.S3_OpenSearch_Backup_Policy[0].arn
  role       = aws_iam_role.S3_OpenSearch_Backup[0].name
}

# =============================================
# Policies para Snapshot Backup (OpenSearch service → S3)
# =============================================

resource "aws_iam_role" "OpenSearch_Snapshot_Backup" {
  name = "OpenSearch_SaaS_Snapshot_Backup_${var.region}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = { Service = "es.amazonaws.com" }
        Effect    = "Allow"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_policy" "OpenSearch_Snapshot_Backup_Policy_S3" {
  name = "OpenSearch_SaaS_Snapshot_Backup_Policy_S3_${var.region}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "role_OpenSearch_Snapshot_Backup_Policy_S3" {
  policy_arn = aws_iam_policy.OpenSearch_Snapshot_Backup_Policy_S3.arn
  role       = aws_iam_role.OpenSearch_Snapshot_Backup.name
}

resource "aws_iam_policy" "OpenSearch_Snapshot_Backup_Policy_PassRole" {
  name = "OpenSearch_SaaS_Snapshot_Backup_Policy_PassRole_${var.region}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = aws_iam_role.OpenSearch_Snapshot_Backup.arn
      },
      {
        Effect = "Allow"
        Action = [
          "es:ESHttpPut",
          "es:ESHttpGet",
          "es:ESHttpPost",
          "es:ESHttpDelete"
        ]
        Resource = "${aws_opensearch_domain.opensearch.arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "role_OpenSearch_Snapshot_Backup_Policy_PassRole" {
  policy_arn = aws_iam_policy.OpenSearch_Snapshot_Backup_Policy_PassRole.arn
  role       = aws_iam_role.OpenSearch_Snapshot_Backup.name
}