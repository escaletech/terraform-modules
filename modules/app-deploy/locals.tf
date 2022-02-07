locals {
  keel_annotations = merge({
    "keel.sh/pollSchedule" = "@every ${var.keel-interval}m"
    "keel.sh/trigger"      = "poll"
    }, var.tags.Environment == "production" ? {
    "keel.sh/policy" = "all"
    } : {
    "keel.sh/match-tag" = true
    "keel.sh/policy"    = "force"
  })
  datadog_annotations = {
    "ad.datadoghq.com/${var.app-name}.logs" = "[{\"source\":\"${var.logger}\",\"service\":\"${var.app-name}\"}]"
    "ad.datadoghq.com/${var.app-name}.tags" = "{\"environment\":\"${var.tags.Environment}\",\"env\":\"${var.tags.Environment}\",\"service\":\"${var.app-name}\",\"version\":\"${var.image-tag}\"}"
  }
  deployment_annotations = local.keel_annotations
  pod_annotations        = local.datadog_annotations
}
