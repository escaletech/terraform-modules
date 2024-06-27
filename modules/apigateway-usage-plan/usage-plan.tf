resource "aws_api_gateway_api_key" "api_key" {
  name = var.partner
  description = var.description
  enabled = var.key_enabled
}

resource "aws_api_gateway_usage_plan" "usage_plan" {
  name        = var.partner
  description = var.description


  dynamic "api_stages" {
    for_each = var.api_stage
    content {
      api_id = api_stages.value.api_id
      stage = api_stages.value.stage
    }
  }

  dynamic "quota_settings" {
    for_each = var.quota_settings
    content {
        limit = quota_settings.value.limit
        period = quota_settings.value.period
    }
  }
  
  dynamic "throttle_settings" {
    for_each = var.throttle_settings
    content {
        rate_limit = throttle_settings.value.rate_limit
        burst_limit = throttle_settings.value.burst_limit
    }
  }
}

resource "aws_api_gateway_usage_plan_key" "usage_plan_key" {
  key_id        = aws_api_gateway_api_key.api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.usage_plan.id
}