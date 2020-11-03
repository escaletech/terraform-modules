# CDN
This module configs:

- Cloudfront
- Route53
- AWS ACM

### Usage

```tf
module "staging-config" {
  source = "github.com/escaletech/terraform-utils/module/cdn"

  environment       = "staging"
  dns_zone          = "mydnszone.com.br"
  host              = "staging.mydnszone.com.br"
  origin_host       = "apps.eks.mydnszone.com.br"
  whitelisted_names = ["site.com"]
  logging_bucket    = "mylogs.s3.amazonaws.com"

  tags = {
    Name        = "sample"
    Environment = "staging"
  }
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| aws | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cookies\_forward | If you want cloudfront to forward cookies | `string` | `"none"` | no |
| cookies\_whitelisted | If cookies\_forward is whitelist, specify those here | `list(string)` | `null` | no |
| dns\_zone | DNS Zone for subdomain creation | `string` | n/a | yes |
| environment | Deployment environment | `string` | `"staging"` | no |
| host | Host for endpoint access | `string` | n/a | yes |
| logging\_bucket | AWS S3 bucket to store access logs | `string` | n/a | yes |
| origin\_host | Origin host for cloudfront | `string` | n/a | yes |
| tags | Map of tags to identify this resource on AWS | `map` | <pre>{<br>  "Environment": "add-environment",<br>  "Name": "add-application-name",<br>  "Owner": "add-application-owner",<br>  "Repository": "add-github-repository"<br>}</pre> | no |

## Outputs

No output.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
