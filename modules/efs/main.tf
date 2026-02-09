# Security Group específico para o EFS
resource "aws_security_group" "efs" {
  name        = "efs-${var.service_name}"
  description = "Permite NFS porta 2049 apenas das tasks do servico ${var.service_name}"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = var.ecs_task_security_group_ids == null ? [] : var.ecs_task_security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "efs-${var.service_name}"
  })
}

# EFS File System (um por serviço/cliente)
resource "aws_efs_file_system" "this" {
  creation_token   = "${var.service_name}-efs"
  performance_mode = var.performance_mode
  throughput_mode  = var.throughput_mode
  encrypted        = true

  lifecycle_policy {
    transition_to_ia = var.transition_to_ia
  }

  tags = merge(var.tags, {
    Name = "efs-${var.service_name}"
  })
}

# Access Point para mount seguro
resource "aws_efs_access_point" "this" {
  file_system_id = aws_efs_file_system.this.id

  posix_user {
    uid = var.uid
    gid = var.gid
  }

  root_directory {
    path = "/n8n-data"
    creation_info {
      owner_uid   = var.uid
      owner_gid   = var.gid
      permissions = var.root_permissions
    }
  }

  tags = merge(var.tags, {
    Name = "ap-${var.service_name}"
  })
}

# Mount Targets em todas as subnets fornecidas
resource "aws_efs_mount_target" "this" {
  for_each        = toset(var.subnet_ids)
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs.id]
}
