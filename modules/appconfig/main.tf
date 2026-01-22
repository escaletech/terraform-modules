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

resource "aws_appconfig_hosted_configuration_version" "config_version" {
  application_id           = aws_appconfig_application.app.id
  configuration_profile_id = aws_appconfig_configuration_profile.profile.configuration_profile_id
  content_type             = var.content_type
  content                  = var.config_content
  description              = var.config_description
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

resource "aws_appconfig_deployment" "deployment" {
  application_id           = aws_appconfig_application.app.id
  environment_id           = aws_appconfig_environment.env.environment_id
  configuration_profile_id = aws_appconfig_configuration_profile.profile.configuration_profile_id
  configuration_version    = aws_appconfig_hosted_configuration_version.config_version.version_number
  deployment_strategy_id   = aws_appconfig_deployment_strategy.strategy.id
  description              = var.deployment_description
  tags                     = var.tags
}
