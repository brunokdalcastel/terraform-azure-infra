# ADR 001: separar DEV e PROD em root modules

## Status

Aceita em 2026-09-14. Implementada em código; isolamento real pendente.

## Contexto

O portfólio precisa demonstrar separação de ambientes sem duplicar a implementação. PROD é demonstrativo, não um serviço em produção.

## Decisão

Manter [DEV](../../environments/dev/main.tf) e [PROD](../../environments/prod/main.tf) como roots próprios, com inputs, lock files e chaves de state separadas. Ambos usam o [módulo compartilhado](../../modules/app-infrastructure/main.tf).

## Alternativas consideradas

- Um único root alternado por variáveis: menos arquivos, mas contexto de execução menos explícito.
- Copiar todos os módulos por ambiente: maior independência, com duplicação e risco de divergência.

## Consequências

Mudanças compartilhadas exigem avaliar DEV e PROD. Os mocks verificam configuração, sem comprovar isolamento de acesso. Chaves de state distintas não criam separação de RBAC ou assinatura. Os CIDRs padrão coincidem; conectividade entre ambientes exige revisão prévia. Permissões e comportamento real só serão validados na etapa aprovada.

Evidências: [limites do PROD](../../environments/prod/README.md) e [CI](../../.github/workflows/terraform.yml).
