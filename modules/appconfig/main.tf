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

resource "aws_appconfig_hosted_configuration_version" "config_version" {
  count = var.configuration_content != null ? 1 : 0

  application_id          = aws_appconfig_application.app.id
  configuration_profile_id = aws_appconfig_configuration_profile.profile.id
  description             = var.configuration_version_description
  content_type            = var.configuration_content_type
  content                 = var.configuration_content
}
