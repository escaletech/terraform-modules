locals {
  dimensions = {
    DomainName = var.name
    ClientId   = data.aws_caller_identity.current.account_id
  }
}

resource "aws_opensearch_domain" "opensearch" {
  domain_name     = var.name
  engine_version  = var.engine_version
  ip_address_type = "ipv4"
  advanced_options = {
    "indices.fielddata.cache.size"        = "20"
    "indices.query.bool.max_clause_count" = "1024"
    "override_main_response_version"      = "true"
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    anonymous_auth_enabled         = false
    master_user_options {
      master_user_name     = "master"
      master_user_password = aws_secretsmanager_secret_version.dbpass.secret_string
    }
  }

  cluster_config {
    instance_type                 = var.instance_type
    instance_count                = var.instance_count
    dedicated_master_count        = 0
    multi_az_with_standby_enabled = false
    warm_enabled                  = false
    zone_awareness_enabled        = false
  }

  ebs_options {
    ebs_enabled = true
    volume_size = var.volume_size
    iops        = 3000
    throughput  = 125
    volume_type = "gp3"
  }

  node_to_node_encryption {
    enabled = true
  }

  encrypt_at_rest {
    enabled    = true
    kms_key_id = data.aws_kms_key.opensearch.arn
  }

  snapshot_options {
    automated_snapshot_start_hour = 0
  }

  vpc_options {
    subnet_ids         = data.aws_subnet.subnet-private-ids[*].id
    security_group_ids = [aws_security_group.opensearch.id]
  }

  domain_endpoint_options {
    custom_endpoint_enabled         = true
    enforce_https                   = true
    tls_security_policy             = "Policy-Min-TLS-1-0-2019-07"
    custom_endpoint                 = "${var.name}.${var.domain_name}"
    custom_endpoint_certificate_arn = data.aws_acm_certificate.certificate-opensearch.arn
  }

  log_publishing_options {
    cloudwatch_log_group_arn = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/opensearch-service/${var.name}:*"
    enabled                  = false
    log_type                 = "AUDIT_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/opensearch-service/${var.name}:*"
    enabled                  = false
    log_type                 = "ES_APPLICATION_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/opensearch-service/${var.name}:*"
    enabled                  = false
    log_type                 = "SEARCH_SLOW_LOGS"
  }
  access_policies = data.aws_iam_policy_document.policy-opensearch.json

  tags = var.tags
}

data "aws_iam_policy_document" "policy-opensearch" {
  statement {
    sid    = "policyOpenSearch"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["es:*"]
    resources = ["arn:aws:es:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.name}/*"]
  }
}