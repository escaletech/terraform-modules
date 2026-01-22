resource "aws_appconfig_application" "app" {
  name        = var.app_name
  description = var.app_description
  tags        = var.tags
}

resource "aws_appconfig_environment" "env" {
  name           = var.env_name
  description    = var.env_description
  application_id = aws_appconfig_application.app.id
  tags           = var.tags
}

resource "aws_appconfig_configuration_profile" "profile" {
  application_id = aws_appconfig_application.app.id
  name           = var.profile_name
  location_uri   = "hosted"
  tags           = var.tags
}

resource "aws_appconfig_deployment_strategy" "strategy" {
  name                           = "${var.app_name}-${var.deployment_strategy_name}"
  description                    = var.deployment_strategy_description
  deployment_duration_in_minutes = var.deployment_duration_in_minutes
  final_bake_time_in_minutes     = var.final_bake_time_in_minutes
  growth_factor                  = var.growth_factor
  growth_type                    = var.growth_type
  replicate_to                   = var.replicate_to
  tags                           = var.tags
}
