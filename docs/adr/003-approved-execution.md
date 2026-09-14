# ADR 003: separar validação de código de execução aprovada

## Status

Aceita em 2026-09-14. Regra vigente; workflow de deploy não implementado.

## Contexto

O proprietário ainda precisa criar uma conta Azure. O projeto deve evoluir com evidências locais, controle de custos e autorização explícita antes de operar recursos.

## Decisão

O [CI atual](../../.github/workflows/terraform.yml) executa fmt, init sem backend, validate e testes com mocks. Não autentica no Azure nem faz deploy. Checkov é report-only. A execução real fica para a etapa final, após aprovação manual explícita do proprietário, conforme [AGENTS.md](../../AGENTS.md). Merge de código não autoriza deploy.

## Alternativas consideradas

- Executar Azure durante cada parcela: exige conta, acesso e decisões de custo ainda pendentes.
- Deploy automático após merge: não atende à autorização definida para o projeto.

## Consequências

É possível revisar configuração sem criar recursos, mas mocks não comprovam RBAC, conectividade, quotas, preços ou provisionamento. OIDC e workflow de execução manual são etapas futuras. Este ADR não configura aprovação técnica de deploy; a regra documental não substitui esse controle. A futura implementação deverá exigir acionamento manual e aprovação, com escopo e impacto apresentados ao proprietário antes da execução.

Evidência complementar: [processo de revisão](../../CONTRIBUTING.md).
