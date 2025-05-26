data "aws_api_gateway_rest_api" "gateway_api" {
  name = var.gateway_api
}

data "local_file" "deployment_output" {
  depends_on = [null_resource.deploy_gateway]
  filename   = "${path.module}/deployment_output.json"
}