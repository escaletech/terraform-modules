data "aws_caller_identity" "current" {}

locals {
  users_arn = [
    for user in var.iam-users :
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${user}"
      username = user
      groups = [
        "system:masters"
      ]
    }
  ]
}

resource "kubernetes_config_map" "aws_auth_configmap" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
  data = {
    mapRoles = yamlencode([
      {
        rolearn  = data.aws_iam_role.nodes.arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups = [
          "system:bootstrappers",
          "system:nodes"
        ]
      },
      {
        rolearn = var.admin-sso-role
        usename = "adminuser:{{SessionName}}"
        groups = [
          "system:sso-eks-admins"
        ]
      },
      {
        rolearn  = var.viewers-sso-role
        username = "readonlyuser:{{SessionName}}"
        groups = [
          "system:sso-eks-readonly"
        ]
      },
      {
        rolearn  = var.developer-sso-role
        username = "devuser:{{SessionName}}"
        groups = [
          "system:sso-eks-developers"
        ]
      }
    ])

    mapUsers = yamlencode(local.users_arn)
  }
}
