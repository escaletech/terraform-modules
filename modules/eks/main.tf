###############
# Cluster IAM #
###############

data "aws_iam_policy_document" "cluster" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["eks.amazonaws.com"]
      type        = "Service"
    }
  }
}


resource "aws_iam_role" "cluster" {
  name               = "${var.cluster-name}-cluster"
  assume_role_policy = data.aws_iam_policy_document.cluster.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster.name
}

##########################
# Cluster Security Group #
##########################

resource "aws_security_group" "cluster" {
  name        = "${var.cluster-name}-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

######################
# Cluster Definition #
######################

resource "aws_eks_cluster" "cluster" {
  name     = var.cluster-name
  role_arn = aws_iam_role.cluster.arn
  version  = var.eks_version

  vpc_config {
    security_group_ids = [aws_security_group.cluster.id]
    subnet_ids         = concat(var.public_subnet_ids, var.private_subnet_ids)
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster-AmazonEKSVPCResourceController,
    aws_cloudwatch_log_group.log_group
  ]

  tags = var.tags
}

#############
# Nodes IAM #
#############

data "aws_iam_policy_document" "nodes" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "nodes" {
  name               = "${var.cluster-name}-nodes"
  assume_role_policy = data.aws_iam_policy_document.nodes.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_instance_profile" "nodes" {
  name = "${var.cluster-name}-nodes"
  role = aws_iam_role.nodes.name
}


#########################
# Nodes Security Groups #
#########################

resource "aws_security_group" "nodes" {
  name        = "${var.cluster-name}-nodes"
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    "kubernetes.io/cluster/${var.cluster-name}" = "owned"
    }
  )
}

resource "aws_security_group_rule" "nodes-ingress-self" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.nodes.id
  source_security_group_id = aws_security_group.nodes.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "nodes-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.nodes.id
  source_security_group_id = aws_security_group.cluster.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.nodes.id
  to_port                  = 443
  type                     = "ingress"
}

##############
# Node Group #
##############

resource "aws_eks_node_group" "node_group_private" {
  count = length(var.private_subnet_ids)

  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "node-group-private-${count.index}"
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = [var.private_subnet_ids[count.index]]
  instance_types  = [var.node-instance-type]

  scaling_config {
    desired_size = var.asg-desired-capacity
    max_size     = var.asg-max-size
    min_size     = var.asg-min-size
  }

  tags = merge(var.tags, {
    "kubernetes.io/cluster/${aws_eks_cluster.cluster.name}" = "owned",
    "k8s.io/cluster-autoscaler/enabled"                     = "true"
    }
  )

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config[0].desired_size]
  }
}

#resource "aws_autoscaling_group_tag" "nodes_group_name" {
#  depends_on = [aws_eks_node_group.node_group_private]
#  for_each = { for tag in flatten([for asg in flatten(
#    [for resources in flatten(
#      [for ng in aws_eks_node_group.node_group_private : ng.resources]
#    ) : resources.autoscaling_groups]
#    ) : [for k, v in var.tags : { asg = asg.name, key = k, val = v }]
#  ]) : "${tag.asg}-${tag.key}" => { asg = tag.asg, key = tag.key, val = tag.val } }
#
#  autoscaling_group_name = each.value.asg
#
#  tag {
#    key                 = each.value.key
#    value               = each.value.val
#    propagate_at_launch = true
#  }
#}
#
##############
# EKS Addons #
##############

resource "aws_eks_addon" "kube_proxy" {
  cluster_name      = aws_eks_cluster.cluster.name
  addon_name        = "kube-proxy"
  addon_version     = var.kube_proxy_version
  resolve_conflicts = "OVERWRITE"
  tags = merge(var.tags, {
    "eks_addon" = "kube-proxy"
    }
  )
}

resource "aws_eks_addon" "core_dns" {
  cluster_name      = aws_eks_cluster.cluster.name
  addon_name        = "coredns"
  addon_version     = var.core_dns_version
  resolve_conflicts = "OVERWRITE"
  tags = merge(var.tags, {
    "eks_addon" = "coredns"
    }
  )
}

#################
# Retention Log #
#################

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/eks/${var.cluster-name}/cluster"
  retention_in_days = 7
}

data "tls_certificate" "example" {
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.example.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}
