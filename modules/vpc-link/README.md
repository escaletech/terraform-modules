# VPC Link (API Gateway v1)

This module creates an API Gateway **VPC Link (v1 / REST API)** to connect an API Gateway REST API to a **Network Load Balancer (NLB)**.

It does **not** create an API Gateway v2 VPC Link.

## Usage

```hcl
module "vpc_link" {
  source = "./modules/vpc-link"

  name        = "my-api-vpc-link"
  description = "VPC Link for REST API -> NLB"
  target_arns = [aws_lb.nlb.arn]
  tags = {
    Environment = "dev"
  }
}
```

## Inputs

| Name         | Type         | Description                                           | Required |
|--------------|--------------|-------------------------------------------------------|----------|
| `name`       | `string`     | Name for the VPC Link                                 | yes      |
| `description` | `string`    | Optional description                                  | no       |
| `target_arns` | `list(string)` | List of NLB ARNs to attach to the VPC Link          | yes      |
| `tags`       | `map(string)` | Tags to apply                                         | no       |

## Outputs

| Name  | Description            |
|-------|------------------------|
| `id`  | ID of the VPC Link     |
| `name`| Name of the VPC Link   |
| `arn` | ARN of the VPC Link    |
