# Terraform Modules by Escaletech
Useful [terraform](https://www.terraform.io/) modules.

### Available Modules

- [CloudFront Website](./modules/cdn)
- [MySQL](./modules/mysql)
- [RDS PostgreSQL](./modules/rds_postgres)
- [SQS Queue](./modules/sqs_queue)

## Development

Install [pre-commit-terraform](https://github.com/antonbabenko/pre-commit-terraform)

##### MacOS

```bash
brew tap liamg/tfsec
brew install pre-commit gawk terraform-docs tflint tfsec coreutils
```

##### Ubuntu

```bash
sudo apt install python3-pip gawk &&\
pip3 install pre-commit
curl -L "$(curl -s https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest | grep -o -E "https://.+?-linux-amd64")" > terraform-docs && chmod +x terraform-docs && sudo mv terraform-docs /usr/bin/
curl -L "$(curl -s https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E "https://.+?_linux_amd64.zip")" > tflint.zip && unzip tflint.zip && rm tflint.zip && sudo mv tflint /usr/bin/
env GO111MODULE=on go get -u github.com/liamg/tfsec/cmd/tfsec
```

#### Install pre-commit hook globally

```bash
DIR=~/.git-template
git config --global init.templateDir ${DIR}
pre-commit init-templatedir -t pre-commit ${DIR}
```

#### Add Add configs and hooks

```bash
git init
cat <<EOF > .pre-commit-config.yaml
repos:
- repo: git://github.com/antonbabenko/pre-commit-terraform
  rev: v.43.0 # Get the latest from: https://github.com/antonbabenko/pre-commit-terraform/releases
  hooks:
    - id: terraform_fmt
    - id: terraform_docs
EOF
```

#### Run

```bash
pre-commit run -a
```
