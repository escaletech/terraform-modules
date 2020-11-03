# CDN
This module configs:

- MySQL

### Usage

Example show how to use it with rds module

```tf
module "rds" {
  source = "github.com/escaletech/terraform-modules/modules/rds"
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

module "staging-config" {
  source = "github.com/escaletech/terraform-modules/modules/mysql"

  db_host            = module.rds.instance.endpoint
  db_master          = module.rds.instance.username
  db_master_password = module.rds.instance.password
  db_name            = "mydb"
  db_username        = "myuser"
  db_password        = var.password_secret
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| mysql | ~> 1.6 |

## Providers

| Name | Version |
|------|---------|
| mysql | ~> 1.6 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| db\_host | Database host | `string` | n/a | yes |
| db\_master | Master username with database/user creation permission | `string` | n/a | yes |
| db\_master\_password | Master password for user with database/user creation permission | `string` | n/a | yes |
| db\_name | Database name to be created | `string` | n/a | yes |
| db\_password | Password for new user to be created | `string` | n/a | yes |
| db\_username | New user to be created | `string` | n/a | yes |

## Outputs

No output.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
