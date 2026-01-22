# Policies for S3 Backup (condicional no s3.tf)

# Policies for Snapshot Backup
resource "aws_iam_role" "OpenSearch_Snapshot_Backup" {
  name = "OpenSearch_SaaS_Snapshot_Backup"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "es.amazonaws.com"
        }
        Effect = "Allow"
      },
    ]
  })

  tags = var.tags
}

resource "aws_iam_policy" "OpenSearch_Snapshot_Backup_Policy_S3" {
  name = "OpenSearch_SaaS_Snapshot_Backup_Policy_S3"

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
  name = "OpenSearch_SaaS_Snapshot_Backup_Policy_PassRole"

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
        Resource = aws_opensearch_domain.opensearch.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "role_OpenSearch_Snapshot_Backup_Policy_PassRole" {
  policy_arn = aws_iam_policy.OpenSearch_Snapshot_Backup_Policy_PassRole.arn
  role       = aws_iam_role.OpenSearch_Snapshot_Backup.name
}