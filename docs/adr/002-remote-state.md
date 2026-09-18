# ADR 002: backend remoto com bootstrap independente

## Status

Aceita em 2026-09-14. Atualizada após a sessão temporária de 18/09/2026 e sua limpeza.

## Contexto

O destino do state precisa existir antes de ser usado pela aplicação. Seu ciclo de vida e acesso merecem tratamento separado do Storage de dados da aplicação.

## Decisão

Manter um [bootstrap independente](../../bootstrap/backend/README.md) para RG, Storage e container tfstate. Seu state permanece local nesta etapa. Preparar os backends AzureRM de [DEV](../../environments/dev/backend.tf) e [PROD](../../environments/prod/backend.tf) com autenticação Entra ID e chaves dev.terraform.tfstate e prod.terraform.tfstate. Coordenadas reais serão fornecidas somente na inicialização aprovada. A validação atual usa backend desabilitado.

## Alternativas consideradas

- State local permanente da aplicação: dispensa bootstrap, mas não atende ao objetivo de operação remota do projeto.
- Storage da aplicação: mistura o ciclo de vida do state com os recursos que ele gerencia.

## Consequências

Há uma etapa adicional de preparação e proteção do state do bootstrap. Rede, permissões de dados, recuperação e custo de retenção precisam de revisão real. O backend DEV foi inicializado no Azure, sem migração de state existente. Lock real foi observado e blobs sintéticos foram recuperados. Concorrência entre applies e recuperação completa de state continuam pendentes; veja as [evidências](../azure-validation-2026-09-18.md). Chaves separadas não impedem que uma identidade com acesso amplo leia ambos os states.

Evidências e cuidados: [documentação do bootstrap](../../bootstrap/backend/README.md).
