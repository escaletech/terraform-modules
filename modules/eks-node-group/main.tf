resource "aws_eks_node_group" "extra-node-group" {
  cluster_name    = var.eks_cluster_name
  node_group_name = var.node_group_name
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids
  instance_types  = var.node_instance_types

  scaling_config {
    desired_size = var.node_desired_state
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  tags = merge(var.tags, {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned",
    "k8s.io/cluster-autoscaler/enabled"             = "true"
    }
  )

  dynamic "taint" {
    for_each = var.enable_taint ? ["do-it"] : []
    content {
      effect = "NO_SCHEDULE"
      key    = "NoscheduleSnowPlowNode"
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config[0].desired_size]
  }
}

