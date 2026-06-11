# api-gateway

Modulo Terraform para criar um API Gateway REST publico com custom domain (EDGE), Route53 record e policy de invocacao.

## Compressao de respostas (gzip)

Por padrao, o modulo habilita compressao gzip com `minimum_compression_size = 1024` (respostas >= 1 KB). O API Gateway adiciona automaticamente o header `Content-Encoding: gzip` quando o cliente envia `Accept-Encoding: gzip`.

```hcl
module "api_gateway" {
  source = "...//modules/api-gateway"

  name            = "my-api"
  domain          = "api.example.com"
  zone            = "example.com"
  certificate_arn = data.aws_acm_certificate.cert.arn

  # minimum_compression_size = 1024  # default
}
```

### Opt-out e override

```hcl
minimum_compression_size = null  # desabilitar compressao
minimum_compression_size = -1    # comprimir todas as respostas elegiveis
```

Apos alterar a configuracao, e necessario criar um **novo deployment** da API para a compressao entrar em vigor.

## Inputs

| Nome | Tipo | Descricao | Obrigatorio | Default |
|------|------|-----------|-------------|---------|
| `name` | `string` | Nome do API Gateway | sim | - |
| `domain` | `string` | Dominio customizado | sim | - |
| `zone` | `string` | Zona Route53 | sim | - |
| `certificate_arn` | `string` | ARN do certificado ACM | sim | - |
| `private_zone` | `bool` | Se a zona Route53 e privada | nao | `false` |
| `api_key_source` | `string` | Fonte da API Key | nao | `HEADER` |
| `minimum_compression_size` | `number` | Tamanho minimo em bytes para gzip (`1024` default, `-1` para tudo, `null` para desabilitar) | nao | `1024` |

## Documentacao

Consulte [`docs/api-gateway-gzip-compression.md`](../../docs/api-gateway-gzip-compression.md) para detalhes sobre rollout, impacto em consumidores e atendimento a alertas ZaNSHIN.
