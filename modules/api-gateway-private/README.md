# api-gateway-private module

Creates a private API Gateway REST API with a custom domain, Route53 record, and an optional VPC Endpoint.

## Usage

### Use an existing VPC Endpoint

```hcl
module "api_gateway_private" {
  source = "./modules/api-gateway-private"

  name            = "my-private-api"
  domain          = "api.internal.example.com"
  zone            = "internal.example.com"
  private_zone    = true
  certificate_arn = "arn:aws:acm:us-east-1:111111111111:certificate/abcd"

  type_endpoint    = "REGIONAL"
  vpc_endpoint_ids = ["vpce-0123456789abcdef0"]
}
```

### Create a new VPC Endpoint

```hcl
module "api_gateway_private" {
  source = "./modules/api-gateway-private"

  name            = "my-private-api"
  domain          = "api.internal.example.com"
  zone            = "internal.example.com"
  private_zone    = true
  certificate_arn = "arn:aws:acm:us-east-1:111111111111:certificate/abcd"

  type_endpoint     = "REGIONAL"
  create_vpc_endpoint = true
  vpc_id              = "vpc-0123456789abcdef0"
  vpc_endpoint_subnet_ids = [
    "subnet-0c9d8a905b02b1968",
    "subnet-0efd9040b32ebcb85",
  ]
  vpc_endpoint_security_group_ids = ["sg-0123456789abcdef0"]
}
```

## Inputs

| Name | Type | Description | Required | Default |
|------|------|-------------|----------|---------|
| `zone` | `string` | Route53 zone name | yes | n/a |
| `private_zone` | `bool` | Whether the Route53 zone is private | no | `true` |
| `name` | `string` | API Gateway name | yes | n/a |
| `domain` | `string` | Custom domain for the API Gateway | yes | n/a |
| `certificate_arn` | `string` | ACM certificate ARN for the domain | yes | n/a |
| `vpc_endpoint_ids` | `list(string)` | Existing VPC Endpoint IDs | no | `[]` |
| `type_endpoint` | `string` | Custom domain endpoint type: `REGIONAL` or `EDGE` | no | `REGIONAL` |
| `create_vpc_endpoint` | `bool` | Create a VPC Endpoint in this module | no | `false` |
| `vpc_id` | `string` | VPC ID used to create the endpoint | no | `null` |
| `vpc_endpoint_subnet_ids` | `list(string)` | Subnet IDs for the endpoint | no | `[]` |
| `vpc_endpoint_security_group_ids` | `list(string)` | Security Group IDs for the endpoint | no | `[]` |
| `vpc_endpoint_private_dns_enabled` | `bool` | Enable private DNS on the endpoint | no | `true` |
| `vpc_endpoint_service_name` | `string` | Override service name (default uses regional execute-api) | no | `null` |

## Outputs

| Name | Description |
|------|-------------|
| `id` | API Gateway REST API ID |
| `root_resource_api_id` | Root resource ID |
| `gateway_api_arn` | API Gateway ARN |
| `vpc_endpoint_ids` | Effective VPC Endpoint IDs used by the API |

