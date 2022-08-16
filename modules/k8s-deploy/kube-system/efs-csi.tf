data "aws_iam_policy_document" "efs_assume_role_policy" {
  count = var.efs-enabled != true ? 0 : 1
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(local.issuer_url, "https://", "")}:sub"
      values   = [join(":", ["system", "serviceaccount", "kube-system", "efs-csi-controller-sa"])]
    }

    principals {
      identifiers = [local.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "efs-csi-role" {
  count              = var.efs-enabled != true ? 0 : 1
  assume_role_policy = data.aws_iam_policy_document.efs_assume_role_policy[0].json
  name               = "AmazonEKS_EFS_CSI_DriverRole"
}

resource "aws_iam_role_policy_attachment" "efs-csi" {
  count      = var.efs-enabled != true ? 0 : 1
  role       = aws_iam_role.efs-csi-role[0].name
  policy_arn = aws_iam_policy.efs_policy[0].arn
}

resource "kubernetes_service_account" "efs-sa" {
  count = var.efs-enabled != true ? 0 : 1
  metadata {
    name      = "efs-csi-controller-sa"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name" = "aws-efs-csi-driver"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = resource.aws_iam_role.efs-csi-role[0].arn
    }
  }
}

resource "helm_release" "aws-efs-csi-driver" {
  count      = var.efs-enabled != true ? 0 : 1
  name       = "aws-efs-csi-driver"
  chart      = "aws-efs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  version    = "2.2.7"
  namespace  = "kube-system"

  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.us-east-1.amazonaws.com/eks/aws-efs-csi-driver"
  }

  set {
    name  = "controller.serviceAccount.create"
    value = false
  }

  set {
    name  = "controller.serviceAccount.name"
    value = "efs-csi-controller-sa"
  }
}

resource "aws_security_group" "allow_efs" {
  count       = var.efs-enabled != true ? 0 : 1
  name        = "allow_efs"
  description = "Allow EFS inbound traffic"
  vpc_id      = data.aws_vpc.staging.id

  ingress {
    description = "EFS from VPC"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.staging.cidr_block]
  }

  tags = var.tags
}

resource "aws_efs_file_system" "efs-eks" {
  count            = var.efs-enabled != true ? 0 : 1
  performance_mode = "generalPurpose"
  tags             = var.tags
}

resource "aws_efs_mount_target" "efs-eks" {
  count          = var.efs-enabled != true ? 0 : length(data.aws_subnets.staging.ids)
  file_system_id = aws_efs_file_system.efs-eks[0].id
  subnet_id      = data.aws_subnets.staging.ids[count.index]
}
