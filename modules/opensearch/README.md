# OpenSearch Module

Terraform module para criar um dominio AWS OpenSearch com suporte opcional a Cross-Cluster Replication (CCR).

## Recursos criados

- AWS OpenSearch Domain (VPC, encryption, custom endpoint)
- Security Group (portas 443 e 9200)
- Secrets Manager (master password)
- Route53 CNAME record
- IAM Roles/Policies para snapshot backup
- S3 bucket para backup (opcional)
- CCR outbound/inbound connection (opcional)

## Uso basico (sem CCR)

Cria um dominio OpenSearch standalone, sem replicacao. Nenhuma configuracao de CCR e necessaria.

```hcl
module "opensearch" {
  source = "github.com/escaletech/terraform-modules/modules/opensearch"

  region         = "us-east-1"
  name           = "my-opensearch"
  domain_name    = "example.internal"
  vpc            = "my-vpc"
  subnet         = ["private-subnet-1"]
  instance_type  = "r6g.large.search"
  instance_count = 1
  volume_size    = 100
  bucket_name    = "my-opensearch-backup"

  tags = {
    Environment = "production"
  }
}
```

## Uso com S3 backup

```hcl
module "opensearch" {
  source = "github.com/escaletech/terraform-modules/modules/opensearch"

  region           = "us-east-1"
  name             = "my-opensearch"
  domain_name      = "example.internal"
  vpc              = "my-vpc"
  subnet           = ["private-subnet-1"]
  instance_type    = "r6g.large.search"
  instance_count   = 1
  volume_size      = 100
  bucket_name      = "my-opensearch-backup"
  enable_s3_backup = true
}
```

## Uso com CCR (Cross-Cluster Replication)

CCR permite replicar indices de um dominio (leader) para outro (follower) para alta disponibilidade ou leitura em outra regiao.

O fluxo de conexao funciona assim:

1. O **leader** cria uma conexao outbound (`remote_domain`) apontando para o follower
2. O **follower** aceita a conexao inbound (`accept_inbound_connection_id`) usando o ID gerado pelo leader

Ambos os lados precisam ser declarados. O leader precisa existir primeiro para gerar o `ccr_outbound_connection_id` que o follower vai consumir.

### Leader (source) - `remote_domain`

Configura este dominio como **leader/source** da replicacao. Ao definir `remote_domain`, o modulo cria um `aws_opensearch_outbound_connection` que inicia o pedido de conexao para o dominio remoto.

Voce precisa informar:
- `domain_name`: nome do dominio OpenSearch de destino (follower)
- `region`: regiao AWS onde o follower esta
- `owner_id`: AWS Account ID do dono do dominio follower (pode ser a mesma conta)

```hcl
module "opensearch_leader" {
  source = "github.com/escaletech/terraform-modules/modules/opensearch"

  region         = "us-east-1"
  name           = "opensearch-leader"
  domain_name    = "example.internal"
  vpc            = "my-vpc"
  subnet         = ["private-subnet-1"]
  instance_type  = "r6g.large.search"
  instance_count = 1
  volume_size    = 100
  bucket_name    = "opensearch-leader-backup"

  ccr = {
    remote_domain = {
      domain_name = "opensearch-follower"
      region      = "us-west-2"
      owner_id    = "123456789012"
    }
  }
}
```

### Follower (destination) - `accept_inbound_connection_id`

Configura este dominio como **follower/destination** da replicacao. Ao definir `accept_inbound_connection_id`, o modulo cria um `aws_opensearch_inbound_connection_accepter` que aceita a conexao iniciada pelo leader.

O valor vem do output `ccr_outbound_connection_id` do modulo leader.

```hcl
module "opensearch_follower" {
  source = "github.com/escaletech/terraform-modules/modules/opensearch"

  region         = "us-west-2"
  name           = "opensearch-follower"
  domain_name    = "example.internal"
  vpc            = "my-vpc-west"
  subnet         = ["private-subnet-1"]
  instance_type  = "r6g.large.search"
  instance_count = 1
  volume_size    = 100
  bucket_name    = "opensearch-follower-backup"

  ccr = {
    accept_inbound_connection_id = module.opensearch_leader.ccr_outbound_connection_id
  }
}
```

### `connection_mode`: DIRECT vs VPC_ENDPOINT

| | `DIRECT` (default) | `VPC_ENDPOINT` |
|---|---|---|
| **Como funciona** | Conexao gerenciada pela AWS internamente entre os dominios | Conexao privada via AWS PrivateLink |
| **Cross-region** | Sim | Nao - ambos os dominios devem estar na mesma regiao |
| **Cross-account** | Sim | Sim |
| **Requisito de VPC** | Funciona com dominios publicos ou VPC | Ambos os dominios devem estar em VPC |
| **Quando usar** | Replicacao entre regioes diferentes (cenario mais comum) | Dominios na mesma regiao que precisam de conectividade totalmente privada via VPC |

**Resumo**: use `DIRECT` (default) para cross-region. Use `VPC_ENDPOINT` apenas se os dois dominios estao na mesma regiao e voce precisa que o trafego fique 100% dentro da VPC via PrivateLink.

```hcl
# Exemplo: dois dominios na mesma regiao com PrivateLink
module "opensearch_leader" {
  source = "github.com/escaletech/terraform-modules/modules/opensearch"

  region         = "us-east-1"
  name           = "opensearch-leader"
  # ... demais variaveis ...

  ccr = {
    connection_mode = "VPC_ENDPOINT"
    remote_domain = {
      domain_name = "opensearch-follower"
      region      = "us-east-1"          # mesma regiao obrigatoriamente
      owner_id    = "123456789012"
    }
  }
}
```

### Preciso sempre declarar leader e follower?

Sim. O CCR exige os dois lados configurados:

- **Leader**: declara `remote_domain` -> cria o pedido de conexao outbound
- **Follower**: declara `accept_inbound_connection_id` -> aceita a conexao inbound

O Terraform cria os recursos nessa ordem por causa da dependencia implicita (`module.opensearch_leader.ccr_outbound_connection_id`).

Se voce quer apenas um dominio standalone sem replicacao, simplesmente nao passe a variavel `ccr` (ou passe `ccr = null`).

## Variables

| Nome | Tipo | Default | Obrigatorio | Descricao |
|------|------|---------|-------------|-----------|
| `region` | `string` | - | sim | AWS region |
| `vpc` | `string` | - | sim | VPC name tag |
| `name` | `string` | - | sim | Nome do dominio OpenSearch |
| `domain_name` | `string` | - | sim | Domain name para DNS e custom endpoint |
| `bucket_name` | `string` | - | sim | Nome do bucket S3 para backups |
| `instance_type` | `string` | - | sim | Tipo da instancia OpenSearch |
| `subnet` | `list(string)` | - | sim | Nomes das subnets privadas |
| `volume_size` | `number` | - | sim | Tamanho do volume EBS em GB |
| `instance_count` | `number` | - | sim | Numero de instancias |
| `engine_version` | `string` | `"OpenSearch_2.15"` | nao | Versao do OpenSearch |
| `enable_s3_backup` | `bool` | `false` | nao | Habilitar bucket S3 para backup |
| `ingress_cidrs` | `list(string)` | `["172.26.0.0/16", "172.16.0.0/16", "10.212.0.0/16"]` | nao | CIDRs para ingress no security group |
| `tags` | `map(string)` | `{}` | nao | Tags dos recursos |
| `ccr` | `object` | `null` | nao | Configuracao de CCR (ver abaixo) |

### CCR object

| Campo | Tipo | Default | Descricao |
|-------|------|---------|-----------|
| `connection_alias` | `string` | `""` | Alias da conexao (auto-gerado: `{name}-to-{remote_domain_name}`) |
| `connection_mode` | `string` | `"DIRECT"` | `DIRECT` para cross-region, `VPC_ENDPOINT` para mesma regiao via PrivateLink |
| `remote_domain` | `object` | `null` | Define este dominio como **leader** - cria conexao outbound |
| `remote_domain.domain_name` | `string` | - | Nome do dominio remoto (follower) |
| `remote_domain.region` | `string` | - | Region do dominio remoto |
| `remote_domain.owner_id` | `string` | - | AWS Account ID do dominio remoto |
| `accept_inbound_connection_id` | `string` | `""` | Define este dominio como **follower** - aceita conexao do leader |

## Outputs

| Nome | Descricao |
|------|-----------|
| `opensearch_endpoint` | ARN do dominio OpenSearch |
| `opensearch_arn` | ARN do dominio OpenSearch |
| `opensearch_domain_name` | Nome do dominio OpenSearch |
| `snapshot_backup_role_arn` | ARN da role de snapshot backup |
| `ccr_outbound_connection_id` | ID da conexao outbound CCR (null se CCR desabilitado) |
| `ccr_outbound_connection_status` | Status da conexao outbound CCR (null se CCR desabilitado) |
| `ccr_inbound_connection_id` | ID da conexao inbound aceita (null se nao aplicavel) |
