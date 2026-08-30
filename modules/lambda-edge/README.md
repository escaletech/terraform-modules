# Lambda@Edge

This module deploys a Lambda@Edge function (published version) with IAM role for CloudFront association.

### Usage

```tf
module "edge_security_headers" {
  source = "github.com/escaletech/terraform-modules/modules/lambda-edge"

  lambda_file           = "path/to/handler.js"
  lambda_edge_role_name = "my-edge-role"
  lambda_function_name  = "my-edge-headers"

  tags = {
    Name        = "my-edge-headers"
    Environment = "production"
  }
}
```

### X-Ray tracing and cost

Lambda@Edge runs on every CloudFront request that triggers the associated event. X-Ray charges per trace recorded (~$5 per million after the 100k/month free tier).

| Mode | Default | Behavior | X-Ray cost |
|------|---------|----------|------------|
| `PassThrough` | yes | Propagates trace context; does not create segments | ~zero |
| `Off` | no | Tracing disabled | zero |
| `Active` | no | Creates sampled segments (1 req/s + 5%) | scales with traffic |

**Recommendation:** keep the default `PassThrough` for edge functions (e.g. security headers). Use `Active` only when end-to-end distributed tracing at the edge is required.

```tf
# Explicit opt-in to active tracing (higher X-Ray cost on high-traffic distributions)
lambda_tracing_mode = "Active"

# Fully disable tracing
lambda_tracing_mode = "Off"
```

IAM permissions for X-Ray are attached only when `lambda_tracing_mode = "Active"`.
