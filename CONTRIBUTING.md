# Contribuir com o projeto

Este portfólio evolui com uma mudança lógica por branch e Pull Request. Comece
pelo estado atual do [README](README.md) e pelas [regras do projeto](AGENTS.md).
O [plano](PROJECT_PLAN.md) inclui etapas futuras; não representa entregas concluídas.

## Fluxo de revisão

1. Crie uma branch a partir de main atualizado e delimite o problema.
2. Implemente a mudança e atualize a documentação afetada.
3. Valide conforme o escopo e registre os resultados no modelo de PR.
4. Revise o diff para evitar arquivos locais, credenciais e mudanças fora do escopo.
5. Abra a PR e confira os checks e o conteúdo antes do merge.

Para alterações Terraform, siga os comandos de [validação sem Azure](README.md#validação-sem-conta-azure)
nos roots afetados: DEV, PROD e/ou bootstrap/backend. Uma alteração em módulo
compartilhado pode afetar DEV e PROD. Preserve os lock files e use testes com mocks.
Para documentação, revise conteúdo, links relativos e `git diff --check`;
não é necessário repetir testes Terraform quando nenhum código mudou.

Execute também o [TFLint](docs/tflint.md) na raiz para alterações Terraform. O CI executa lint recursivo, fmt, init sem backend, validate e testes simulados nos três
roots. O Checkov é report-only: um check verde não comprova ausência de findings.
Registre falhas e limitações; não substitua evidência por uma caixa marcada.

## Limite da autorização

Não executar autenticação ou comandos contra Azure, plan com providers reais,
bootstrap, migração de state, apply, destroy, import ou alterações de permissões.
A etapa real depende de conta Azure e aprovação manual explícita do proprietário.
Merge de código não autoriza deploy.

Não versionar credenciais, chaves privadas, state, planos salvos ou tfvars reais.
Use placeholders nos exemplos. Mudanças de rede, autenticação ou endereços de
recursos devem explicar possíveis interrupções e efeitos no state existente.

Este documento e o modelo de PR orientam a revisão humana. Eles não configuram
proteção de branch, revisores obrigatórios ou aprovação de environments no GitHub.
