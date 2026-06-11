# Compressão gzip no API Gateway

Documentação das alterações para habilitar compressão de respostas via `minimum_compression_size` nos módulos de API Gateway REST.

## Contexto

Análise identificou que nenhum módulo de API Gateway neste repositório configurava compressão gzip. Alertas ZaNSHIN apontavam:

> *Configure o API Gateway para utilizar Content Encoding e comprimir a resposta das requisições*

## Solução

Adicionada a variável `minimum_compression_size` nos módulos que criam o REST API:

- [`modules/api-gateway/`](../modules/api-gateway/)
- [`modules/api-gateway-private/`](../modules/api-gateway-private/)

### Comportamento

| Valor | Efeito |
|-------|--------|
| `1024` (default) | Comprime respostas elegíveis >= 1 KB |
| `-1` | Comprime todas as respostas elegíveis |
| `null` | Desabilita compressão (opt-out) |

A compressão ocorre quando:

1. A resposta atinge o tamanho mínimo configurado
2. O cliente envia `Accept-Encoding: gzip`
3. O `Content-Type` é elegível (`application/json`, `text/html`, `text/plain`, etc.)

O API Gateway adiciona automaticamente o header `Content-Encoding: gzip` — não é necessário configurar encoding nas integrações.

## Módulos alterados

| Módulo | Arquivo | Alteração |
|--------|---------|-----------|
| `api-gateway` | `variables.tf` | Nova variável `minimum_compression_size` (default `1024`) |
| `api-gateway` | `gateway.tf` | `minimum_compression_size` no `aws_api_gateway_rest_api` |
| `api-gateway-private` | `variables.tf` | Nova variável `minimum_compression_size` (default `1024`) |
| `api-gateway-private` | `gateway.tf` | `minimum_compression_size` no `aws_api_gateway_rest_api` |

## Módulos fora de escopo

| Módulo | Motivo |
|--------|--------|
| `api-gateway-stage` | Compressão é atributo do REST API, não do stage |
| `api-gateway-method-integration-*` | Integrações não controlam gzip no REST API v1 |
| `stack-saas` | Referencia API existente via data source; beneficia via `api-gateway-private` |

## Rollout

Após atualizar a referência do módulo:

1. Executar `terraform apply` (REST API recebe `minimum_compression_size = 1024`)
2. **Criar novo deployment** e atualizar o stage — obrigatório para gzip entrar em vigor
3. Validar com curl:

```bash
# Resposta >= 1 KB: deve retornar Content-Encoding: gzip
curl -H "Accept-Encoding: gzip" -I https://api.exemplo.com/rota-grande

# Resposta < 1 KB: não deve comprimir
curl -H "Accept-Encoding: gzip" -I https://api.exemplo.com/health
```

### Opt-out

Stacks que precisarem desabilitar a compressão:

```hcl
module "api_gateway" {
  source = "...//modules/api-gateway-private"
  # ...
  minimum_compression_size = null
}
```

### Compressão total

```hcl
minimum_compression_size = -1
```

## Impacto em consumidores

| Cenário | Impacto |
|---------|---------|
| Browsers, fetch, axios, mobile | Nenhum — descompressão transparente |
| Respostas < 1 KB | Nenhum — abaixo do threshold |
| Clientes sem `Accept-Encoding: gzip` | Nenhum |
| Content-types binários | Nenhum — não elegíveis |
| Cliente customizado que não descomprime gzip | Alto — raro; usar `null` para opt-out |

## Atendimento ZaNSHIN

A configuração de `minimum_compression_size > 0` atende o requisito de compressão habilitada no REST API. Para os alertas sumirem, cada API precisa de apply + redeploy. O scanner reavalia após a configuração estar ativa.
