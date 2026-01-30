# Route53 DNS Record Module

Simple Terraform module to create a single Route 53 record using an alias target.

## Usage

```hcl
module "dns_record" {
  source = "./modules/dns-record"

  zone_id      = "Z1234567890ABC"
  record_name  = "app.example.com"
  record_type  = "A"

  alias_name    = "alb-123.us-east-1.elb.amazonaws.com"
  alias_zone_id = "Z35SXDOTRQ7X7K"
}
```

## Inputs

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| zone_id | string | null | Route 53 zone ID. |
| record_name | string | null | Route 53 record name (e.g., `www.example.com.`). |
| private_zone | bool | false | Whether the zone lookup is for a private zone. |
| record_type | string | "A" | Route 53 record type (e.g., A, CNAME, TXT). |
| alias_name | string | null | ALB/NLB target DNS name. |
| alias_zone_id | string | null | ALB/NLB hosted zone ID. |
| default_ttl | number | 300 | Default TTL (not used for alias records). |
| allow_overwrite | bool | true | Whether to allow overwriting existing records. |

## Outputs

| Name | Description |
| --- | --- |
| record_fqdn | Record FQDN. |
| record_id | Record ID. |
