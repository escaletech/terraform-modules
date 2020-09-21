# website
Esse modulo configura:

- Cloudfront
- Route53
- AWS ACM

### Utilização

```tf
module "staging-config" {
  source = "github.com/escaletech/terraform-utils/module/website"

  environment       = "staging"
  dns_zone          = "mydnszone.com.br"
  host              = "staging.mydnszone.com.br"
  origin_host       = "apps.eks.mydnszone.com.br"
  whitelisted_names = ['site.com']
  logging_bucket    = 'mylogs.s3.amazonaws.com'

  tags = {
    Name        = "sample"
    Environment = "staging"
  }
}
```
