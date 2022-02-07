resource "aws_secretsmanager_secret" "secret" {
  count = var.secrets != null ? 1 : 0
  name  = "${var.app-name}/env/${var.tags.Environment}"
  tags  = var.tags
}

resource "kubernetes_manifest" "secret" {
  count = var.secrets != null ? 1 : 0
  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1alpha1"
    kind       = "SecretProviderClass"
    metadata = {
      name      = var.app-name
      namespace = var.namespace
    }
    spec = {
      provider = "aws"
      secretObjects = [
        {
          secretName = var.app-name
          type       = "Opaque"
          data = [
            for key in var.secrets :
            {
              objectName = key
              key        = key
            }
          ]
        }
      ]
      parameters = {
        objects = yamlencode([
          {
            objectName = aws_secretsmanager_secret.secret[count.index].name
            objectType = "secretsmanager"
            jmesPath = [
              for key in var.secrets :
              {
                path        = key
                objectAlias = key
              }
            ]
          }
        ])
      }
    }
  }
}


resource "aws_iam_policy" "secret" {
  count = var.secrets != null ? 1 : 0
  name  = var.app-name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Effect   = "Allow"
        Resource = aws_secretsmanager_secret.secret[count.index].arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secret-attach" {
  count      = var.secrets != null ? 1 : 0
  role       = var.namespace
  policy_arn = aws_iam_policy.secret[count.index].arn
}
