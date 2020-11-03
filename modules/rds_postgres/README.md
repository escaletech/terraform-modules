# CDN
This module configs:

- PostgreSQL RDS

### Usage

Example show how to use it with rds module

```tf
module "postgres_rds" {
  source = "github.com/escaletech/terraform-modules/modules/postgres_rds"
  identifier                = "mydb"
  environment               = "staging"
  instance_class            = "db.t3.micro"
  final_snapshot_identifier = "mydb-staging-final"
  allocated_storage         = 100
  availability_zone         = "us-east-1a"
  multi_az                  = false
  tags = {
    Name        = "mydb"
    Owner       = "myteam"
    Environment = "staging"
    Repository  = "https://github.com/myuser/myrepo"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| aws | ~> 3.0 |
| random | ~> 2.3 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.0 |
| random | ~> 2.3 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allocated\_storage | Pre-allocated storage in MB | `number` | `100` | no |
| availability\_zone | Availability zone | `string` | `"us-east-1c"` | no |
| environment | Deployment environment | `string` | n/a | yes |
| final\_snapshot\_identifier | Final snapshot identifier (for when this database is deleted) | `string` | n/a | yes |
| identifier | RDS identifier | `string` | n/a | yes |
| instance\_class | RDS instance class | `string` | `"db.t3.micro"` | no |
| tags | Map of tags to identify this resource on AWS | `map` | <pre>{<br>  "Environment": "add-environment",<br>  "Name": "add-application-name",<br>  "Owner": "add-application-owner",<br>  "Repository": "add-github-repository"<br>}</pre> | no |

## Outputs

No output.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
