# api-gateway

Terraform module to create an API Gateway REST API with a custom domain and Route53 alias record.

## Usage (EDGE - default)

```hcl
module "api_gateway" {
  source = "./modules/api-gateway"

  name            = "my-api"
  domain          = "api.example.com"
  zone            = "example.com."
  certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/xxxx"
}
```

## Usage (REGIONAL)

```hcl
module "api_gateway" {
  source = "./modules/api-gateway"

  name            = "my-api"
  domain          = "api.example.com"
  zone            = "example.com."
  certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/xxxx"
  endpoint_type   = "REGIONAL"
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `api_key_source` | `string` | `"HEADER"` | API Key Source. |
| `certificate_arn` | `string` | n/a | ACM certificate ARN. For `EDGE`, must be in `us-east-1`. For `REGIONAL`, must be in the same region as the API Gateway. |
| `domain` | `string` | n/a | Custom domain for the API Gateway. |
| `endpoint_type` | `string` | `"EDGE"` | Endpoint type for the custom domain. Allowed values: `EDGE`, `REGIONAL`. |
| `name` | `string` | n/a | API Gateway name. |
| `private_zone` | `bool` | `false` | Whether the Route53 zone is private. |
| `zone` | `string` | n/a | Route53 zone name (e.g. `example.com.`). |

## Outputs

| Name | Description |
|---|---|
| `id` | API Gateway REST API ID. |
| `root_resource_api_id` | API Gateway root resource ID. |

## Notes

- The Route53 record is created as an alias to the API Gateway custom domain.
- The module looks up the Route53 zone by name and `private_zone`.
