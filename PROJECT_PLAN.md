# PROJECT_PLAN.md — Evolução Profissional do `terraform-azure-infra`

> Atualização do proprietário: este projeto é um portfólio para entrevistas.
> Toda execução Azure fica para o final, após criação da conta e aprovação manual.
> Esta regra prevalece sobre os exemplos abaixo de apply após merge.
> Merge não autoriza deploy; o fluxo final deverá ser manual e aprovado.

## 1. Objetivo

Este documento orienta o Codex a evoluir o repositório:

`brunokdalcastel/terraform-azure-infra`

de um laboratório funcional de Terraform + Azure para um projeto com práticas próximas às usadas em ambientes profissionais.

O objetivo principal **não é aumentar a quantidade de recursos Azure**, mas demonstrar maturidade operacional em:

- Infrastructure as Code com Terraform
- Remote State
- State Locking
- Separação de ambientes
- GitHub Actions
- Pull Requests
- OIDC / Workload Identity Federation
- Segurança de IaC
- Controle de versões
- Naming convention
- Tags e FinOps
- Documentação técnica
- Mudanças pequenas e auditáveis

O projeto deve continuar sendo **barato para executar em uma assinatura pessoal do Azure**.

---

# 2. Contexto atual do repositório

O repositório já possui:

- `environments/dev`
- módulos reutilizáveis
- módulo de rede
- módulo de compute
- módulo de storage
- módulo de security
- módulo orquestrador `app-infrastructure`
- arquitetura Azure em três camadas
- Virtual Network
- Subnets
- Network Security Groups
- Linux VMs
- Storage Account
- Azure Key Vault
- GitHub Actions
- `terraform fmt`
- `terraform validate`
- Checkov
- terraform-docs
- estrutura inicial de CI

O ambiente atual utiliza backend local:

```hcl
backend "local" {
  path = "terraform.tfstate"
}
```

Esse será um dos primeiros pontos a ser evoluído.

---

# 3. Princípios obrigatórios

O Codex deve seguir estas regras durante TODO o projeto.

## 3.1 Não reescrever o projeto inteiro

Não substituir toda a estrutura existente.

A evolução deve ser incremental.

Preferir:

```text
mudança pequena
→ validação
→ commit
→ Pull Request
→ revisão
→ merge
```

em vez de uma grande refatoração.

---

## 3.2 Uma mudança lógica por Pull Request

Cada PR deve ter um objetivo claro.

Exemplos:

```text
PR #1 - preparar backend remoto
PR #2 - implementar remote state
PR #3 - adicionar TFLint
PR #4 - configurar OIDC
PR #5 - adicionar terraform plan no PR
```

Evitar PRs que alterem dezenas de coisas sem relação direta.

---

## 3.3 Nunca commitar segredos

Nunca adicionar ao Git:

```text
client_secret
password
access_key
SAS token
terraform.tfstate
terraform.tfstate.backup
*.tfvars com valores sensíveis
.env
credentials
```

Se algum segredo já estiver versionado, informar antes de modificar qualquer coisa.

---

## 3.4 Nunca commitar Terraform State

Garantir no `.gitignore`:

```gitignore
*.tfstate
*.tfstate.*
.terraform/
crash.log
crash.*.log
*.tfplan
```

O state deve ficar em backend remoto.

---

## 3.5 Não criar serviços Azure caros sem necessidade

Não adicionar automaticamente:

- Azure Firewall
- Azure Bastion
- VPN Gateway
- NAT Gateway
- Application Gateway
- AKS
- SQL Managed Instance
- Azure Database premium
- VMs grandes
- Log Analytics com ingestão elevada
- Defender pago
- serviços Premium

Qualquer recurso com potencial de custo relevante deve ser apresentado primeiro como proposta.

---

## 3.6 Priorizar recursos baratos

Preferir:

- Resource Groups
- VNet
- Subnets
- NSGs
- Storage Account LRS
- Managed Identity
- Key Vault quando necessário
- VMs B-series somente em testes
- recursos destruíveis após validação

O projeto deve conseguir demonstrar práticas profissionais mesmo quando a maior parte da infraestrutura estiver destruída.

---

# 4. Arquitetura alvo do projeto

A estrutura alvo aproximada será:

```text
terraform-azure-infra/
│
├── .github/
│   └── workflows/
│       ├── terraform-pr.yml
│       ├── terraform-apply.yml
│       └── terraform-security.yml
│
├── bootstrap/
│   ├── backend/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   │
│   └── oidc/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── versions.tf
│
├── environments/
│   ├── dev/
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfvars.example
│   │
│   └── prod/
│       ├── backend.tf
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── terraform.tfvars.example
│
├── modules/
│   ├── app-infrastructure/
│   ├── network/
│   ├── compute/
│   ├── storage/
│   └── security/
│
├── docs/
│   ├── architecture.md
│   ├── deployment-flow.md
│   ├── cost-control.md
│   └── adr/
│
├── .gitignore
├── .editorconfig
├── .tflint.hcl
├── CONTRIBUTING.md
├── PROJECT_PLAN.md
├── README.md
└── LICENSE
```

Essa estrutura é uma direção, não uma obrigação absoluta.

Antes de mover arquivos existentes, analisar impacto e evitar mudanças desnecessárias.

---

# 5. Fluxo profissional alvo

O fluxo final deve demonstrar:

```text
Developer
   │
   ↓
feature branch
   │
   ↓
Pull Request
   │
   ├── terraform fmt -check
   ├── terraform init
   ├── terraform validate
   ├── TFLint
   ├── Checkov ou Trivy
   └── terraform plan
   │
   ↓
review
   │
   ↓
merge para main
   │
   ↓
GitHub Actions
   │
   ↓
OIDC
   │
   ↓
Microsoft Entra ID
   │
   ↓
Terraform Apply
   │
   ↓
Azure
```

Não usar credencial de Azure com `client_secret` de longa duração no pipeline.

---

# 6. Fase 0 — Auditoria inicial

Antes de modificar arquivos:

1. analisar todo o repositório;
2. identificar dependências entre módulos;
3. analisar `.gitignore`;
4. analisar workflows;
5. verificar provider versions;
6. verificar `.terraform.lock.hcl`;
7. identificar secrets ou states eventualmente versionados;
8. identificar inconsistências entre README e código;
9. executar, quando possível:

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

## Entrega

Criar um resumo contendo:

```text
Current State
Problems Found
Risks
Recommended Changes
```

Não alterar arquitetura nessa fase sem necessidade.

---

# 7. Fase 1 — Higiene e versionamento

## Objetivo

Preparar o projeto para uso consistente por diferentes máquinas e pipelines.

## Implementar

Revisar:

```hcl
required_version
required_providers
```

Evitar versões completamente abertas.

Usar constraints compatíveis com a versão atual do projeto.

Exemplo conceitual:

```hcl
terraform {
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.x"
    }
  }
}
```

Não alterar major versions automaticamente sem avaliar breaking changes.

### `.terraform.lock.hcl`

O lock file deve ser versionado quando apropriado para os root modules usados em CI/CD.

Nunca adicionar:

```text
.terraform/
```

---

## Critério de aceite

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

devem funcionar.

---

# 8. Fase 2 — Bootstrap do Terraform Backend

## Objetivo

Criar infraestrutura mínima para armazenar Terraform State remotamente.

Criar:

```text
bootstrap/backend/
```

Esse bootstrap pode inicialmente utilizar state local porque ele é responsável por criar o backend remoto.

Criar somente:

```text
Resource Group
└── Storage Account
    └── Blob Container: tfstate
```

Sugestão conceitual:

```text
rg-tfstate
└── Storage Account Standard LRS
    └── tfstate
```

## Segurança

Configurar quando compatível:

```text
HTTPS only
TLS mínimo apropriado
public nested items disabled quando possível
blob versioning se custo/complexidade aceitáveis
```

Não armazenar access keys no repositório.

Preferir autenticação via Microsoft Entra ID.

---

# 9. Fase 3 — Remote State

Substituir o backend local do ambiente `dev`.

De:

```hcl
backend "local" {
  path = "terraform.tfstate"
}
```

Para backend AzureRM.

Exemplo conceitual:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "..."
    storage_account_name = "..."
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
    use_azuread_auth     = true
  }
}
```

Credenciais não devem ser hardcoded.

O backend `azurerm` oferece state locking através do Azure Blob Storage.

---

## Separação de states

Usar states diferentes:

```text
dev.terraform.tfstate
prod.terraform.tfstate
```

Nunca compartilhar o mesmo state entre dev e prod.

---

## Migração

Quando aplicável:

```bash
terraform init -migrate-state
```

Antes de executar, explicar ao usuário o que será migrado.

Nunca executar operações destrutivas automaticamente.

---

## Critério de aceite

Confirmar:

```bash
terraform init
terraform plan
```

e verificar que o state está no Azure Storage.

Nenhum `.tfstate` deve aparecer em `git status`.

---

# 10. Fase 4 — Ambiente PROD sem manter infraestrutura cara

Criar:

```text
environments/prod/
```

O objetivo é demonstrar separação profissional de ambientes.

Não é obrigatório provisionar permanentemente o ambiente prod.

Estrutura:

```text
dev
prod
```

com:

- state separado;
- valores de variáveis separados;
- naming separado;
- possibilidade de políticas diferentes.

Exemplo:

```text
rg-project-dev
rg-project-prod
```

O ambiente `prod` deve poder ser validado via:

```bash
terraform init
terraform validate
terraform plan
```

sem necessariamente permanecer provisionado.

---

# 11. Fase 5 — Naming Convention

Centralizar e padronizar nomes.

Exemplos:

```text
rg-brs-app-dev
vnet-brs-app-dev-01
snet-web
snet-app
snet-data
nsg-web
nsg-app
stappdev001
kv-app-dev-001
```

Evitar duplicação de lógica de naming.

Usar `locals` quando apropriado.

Exemplo:

```hcl
locals {
  name_prefix = "${var.project_name}-${var.environment}"
}
```

Não exagerar em abstrações.

---

# 12. Fase 6 — Tags e FinOps

Definir tags padrão.

Exemplo:

```hcl
locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = var.project_name
    Owner       = var.owner
  }
}
```

Quando fizer sentido, incluir:

```text
CostCenter
Workload
Repository
```

Evitar valores pessoais ou sensíveis.

---

## Objetivo

Demonstrar:

```text
governança
ownership
controle de custo
identificação do ambiente
automação
```

---

# 13. Fase 7 — TFLint

Adicionar:

```text
.tflint.hcl
```

Pipeline:

```text
terraform fmt
terraform validate
tflint
```

TFLint deve detectar:

- problemas de estilo;
- erros de provider;
- configurações suspeitas;
- recursos Azure inválidos quando plugin apropriado estiver configurado.

Evitar transformar todos os warnings em bloqueios imediatamente.

Inicialmente categorizar problemas.

Depois tornar checks importantes obrigatórios.

---

# 14. Fase 8 — Security Scanning

O repositório já usa Checkov.

Revisar a configuração atual.

Hoje scans em modo equivalente a `soft_fail` não devem passar a impressão de que vulnerabilidades são ignoradas.

Estratégia:

```text
primeiro:
report-only

depois:
falhar somente em findings relevantes

final:
bloquear violações críticas/high selecionadas
```

Pode-se manter Checkov ou avaliar Trivy IaC.

Não adicionar duas ferramentas fazendo exatamente o mesmo trabalho sem justificativa.

---

# 15. Fase 9 — OIDC entre GitHub e Azure

## Objetivo

Eliminar secrets permanentes para autenticação do GitHub Actions no Azure.

Arquitetura alvo:

```text
GitHub Actions
      │
      │ OIDC token
      ↓
Microsoft Entra ID
      │
      ↓
Federated Credential
      │
      ↓
Azure Identity
      │
      ↓
Azure Resources
```

Utilizar Workload Identity Federation.

Não usar:

```text
ARM_CLIENT_SECRET
AZURE_CLIENT_SECRET
Service Principal password
```

como solução final.

---

## Permissões

Aplicar princípio de least privilege.

Não conceder automaticamente:

```text
Owner
```

na subscription inteira.

Avaliar se `Contributor` ou roles menores são suficientes no Resource Group alvo.

Para acesso ao state, conceder somente as permissões necessárias ao Blob Storage.

---

# 16. Fase 10 — Workflow de Pull Request

Criar ou refatorar:

```text
.github/workflows/terraform-pr.yml
```

Trigger:

```yaml
pull_request:
  branches:
    - main
```

Executar:

```text
checkout
terraform setup
Azure authentication via OIDC
terraform fmt -check
terraform init
terraform validate
TFLint
security scan
terraform plan
```

O `terraform plan` deve ser somente leitura da mudança proposta.

Nunca executar `apply` em Pull Request.

---

# 17. Fase 11 — Terraform Plan visível no PR

Gerar plan:

```bash
terraform plan -no-color
```

Disponibilizar resultado de forma segura no Pull Request.

Cuidado:

Terraform plan pode conter valores sensíveis.

Antes de publicar plan completo em comentário, avaliar se há secrets ou dados sensíveis.

Preferir resumo seguro quando necessário.

Exemplo:

```text
Terraform Plan

Environment: dev

Resources:
+ 2 to add
~ 1 to change
- 0 to destroy
```

---

# 18. Fase 12 — Workflow de Apply

Criar:

```text
.github/workflows/terraform-apply.yml
```

Executar somente após merge para `main`, ou via mecanismo explicitamente controlado.

Fluxo:

```text
merge main
→ authenticate via OIDC
→ terraform init
→ terraform plan
→ terraform apply
```

Para PROD, preferir:

```text
GitHub Environment: production
```

com approval/manual gate quando disponível.

---

# 19. Fase 13 — Proteção contra Destroy acidental

Adicionar controles no workflow.

Exemplo de comportamento:

Se plan indicar destruição relevante:

```text
- X to destroy
```

o pipeline deve destacar o risco.

Para recursos críticos, avaliar:

```hcl
lifecycle {
  prevent_destroy = true
}
```

Somente usar `prevent_destroy` quando realmente fizer sentido.

Não adicionar indiscriminadamente.

---

# 20. Fase 14 — Documentação de arquitetura

Criar:

```text
docs/architecture.md
```

Documentar:

```text
GitHub
   │
   ↓
GitHub Actions
   │
   ↓ OIDC
Microsoft Entra ID
   │
   ↓
Azure
   │
   ├── VNet
   ├── Subnets
   ├── NSGs
   ├── Compute
   ├── Storage
   └── Key Vault

Terraform
   │
   ↓
Azure Blob Storage
   └── Remote State
```

Adicionar Mermaid quando útil.

---

# 21. Fase 15 — Architecture Decision Records

Criar:

```text
docs/adr/
```

Exemplo:

```text
0001-use-azure-blob-for-terraform-state.md
0002-use-github-oidc.md
0003-separate-dev-prod-state.md
0004-use-modules.md
```

Formato:

```markdown
# ADR XXXX - Título

## Status

Accepted

## Context

...

## Decision

...

## Consequences

...
```

Isso demonstra maturidade de engenharia.

---

# 22. Fase 16 — Política de custos

Criar:

```text
docs/cost-control.md
```

Explicar que o projeto foi projetado para aprendizado/portfólio profissional com baixo custo.

Classificar recursos:

```text
Always-on / negligible cost
Temporary
Potentially expensive
Not deployed
```

---

## Recursos temporários

VMs devem poder ser:

```text
created
tested
destroyed
```

sem comprometer o restante da arquitetura.

---

# 23. Fase 17 — README profissional

O README final deve deixar claro que o objetivo do projeto é demonstrar práticas profissionais de Azure Infrastructure as Code.

Sugestão:

```text
# Azure Terraform Platform

Production-oriented Infrastructure as Code project for Azure,
focused on Terraform engineering practices rather than large
cloud consumption.
```

Destacar:

- Terraform
- Azure
- Remote State
- State Locking
- Modules
- Multiple Environments
- GitHub Actions
- OIDC
- Pull Request workflow
- IaC Security
- TFLint
- Checkov/Trivy
- FinOps
- Naming convention
- ADRs

---

# 24. Fluxo de branches recomendado

Não fazer tudo em uma branch.

Sequência sugerida:

```text
main
 │
 ├── chore/repository-audit
 │
 ├── feat/terraform-backend-bootstrap
 │
 ├── feat/remote-state-dev
 │
 ├── feat/prod-environment
 │
 ├── chore/tflint
 │
 ├── chore/security-pipeline
 │
 ├── feat/github-azure-oidc
 │
 ├── feat/terraform-pr-plan
 │
 ├── feat/terraform-apply-workflow
 │
 ├── feat/naming-tags
 │
 └── docs/production-architecture
```

Cada branch deve gerar um PR separado.

---

# 25. Ordem recomendada dos Pull Requests

## PR 01 — Repository baseline

Objetivos:

- auditoria;
- `.gitignore`;
- providers;
- Terraform version;
- lock files;
- validações básicas.

---

## PR 02 — Backend bootstrap

Criar:

```text
bootstrap/backend
```

Provisionar Storage Account de Terraform State.

---

## PR 03 — Remote State DEV

Migrar:

```text
environments/dev
```

para backend `azurerm`.

---

## PR 04 — PROD environment

Criar:

```text
environments/prod
```

sem necessariamente provisionar recursos.

---

## PR 05 — Naming + Tags

Padronizar nomes e FinOps.

---

## PR 06 — TFLint

Adicionar linting profissional.

---

## PR 07 — Security pipeline

Melhorar Checkov ou adotar Trivy.

---

## PR 08 — GitHub → Azure OIDC

Configurar Workload Identity Federation.

---

## PR 09 — Terraform PR workflow

Implementar:

```text
fmt
validate
lint
security
plan
```

---

## PR 10 — Apply workflow

Implementar deploy controlado após merge.

---

## PR 11 — Documentation

Adicionar:

```text
architecture
deployment flow
cost control
ADRs
```

---

# 26. Definition of Done

O projeto só deve ser considerado concluído quando:

- [ ] nenhum Terraform State estiver no Git;
- [ ] state DEV estiver em Azure Blob Storage;
- [ ] state PROD estiver separado;
- [ ] backend usar autenticação segura;
- [ ] `.terraform.lock.hcl` estiver tratado corretamente;
- [ ] providers tiverem version constraints;
- [ ] `terraform fmt` passar;
- [ ] `terraform validate` passar;
- [ ] TFLint estiver configurado;
- [ ] scanner de segurança estiver funcionando;
- [ ] GitHub Actions autenticar com Azure usando OIDC;
- [ ] nenhum client secret permanente estiver no GitHub workflow;
- [ ] Pull Requests executarem `terraform plan`;
- [ ] Pull Requests nunca executarem `terraform apply`;
- [ ] Apply acontecer somente em fluxo controlado;
- [ ] DEV e PROD tiverem states separados;
- [ ] naming convention estiver documentada;
- [ ] tags comuns estiverem implementadas;
- [ ] custo estiver documentado;
- [ ] arquitetura estiver documentada;
- [ ] README representar corretamente o código real.

---

# 27. Regras específicas para o Codex

## Sempre fazer

Antes de mudar código:

1. analisar arquivos relacionados;
2. explicar resumidamente o problema encontrado;
3. explicar a mudança proposta;
4. listar arquivos que serão alterados;
5. realizar a menor alteração possível;
6. executar validações;
7. mostrar o resultado;
8. sugerir mensagem de commit;
9. sugerir título e descrição do PR.

---

## Nunca fazer sem aprovação

Não executar automaticamente:

```bash
terraform apply
terraform destroy
terraform state rm
terraform state mv
terraform import
terraform force-unlock
```

Também não:

- apagar recursos Azure;
- alterar subscription;
- mudar roles amplas;
- criar recursos caros;
- migrar state sem explicar;
- modificar `main` diretamente quando branch/PR for possível.

---

# 28. Formato esperado após cada tarefa

O Codex deve responder aproximadamente neste formato:

```text
## Análise

O que encontrei.

## Mudança

O que foi alterado.

## Arquivos

- arquivo1
- arquivo2

## Validação

terraform fmt: PASS
terraform validate: PASS
tflint: PASS

## Impacto Azure

Nenhum recurso criado.

ou

Recursos que seriam criados:
- X
- Y

## Custo

Estimativa qualitativa:
baixo / temporário / requer atenção

## Próximo passo

...
```

---

# 29. Primeira tarefa do Codex

Começar somente pela auditoria.

Prompt inicial recomendado:

```text
Leia integralmente o arquivo PROJECT_PLAN.md e trate-o como a especificação do projeto.

Analise o estado atual deste repositório sem alterar nenhum arquivo ainda.

Compare a implementação atual com o PROJECT_PLAN.md.

Quero um relatório contendo:

1. estrutura atual;
2. práticas que já estão implementadas;
3. gaps;
4. riscos;
5. inconsistências entre README e código;
6. possíveis custos Azure;
7. arquivos que precisam ser alterados;
8. sequência recomendada de Pull Requests.

Não execute terraform apply ou terraform destroy.
Não crie recursos Azure.
Não faça commits.
Não altere arquivos nesta primeira etapa.

Ao final, proponha apenas o escopo do PR #1.
```

---

# 30. Objetivo profissional do projeto

O resultado final deve permitir apresentar este projeto em entrevistas como:

> Azure Infrastructure as Code platform built with Terraform, featuring reusable modules, remote state with locking, environment isolation, GitHub Actions CI/CD, OIDC authentication, IaC security scanning, governance, tagging and cost-conscious Azure architecture.

O projeto deve demonstrar capacidade de trabalhar como:

```text
Cloud Infrastructure Engineer
Azure Cloud Engineer
Infrastructure Engineer
DevOps Engineer
Platform Engineer - Junior/Mid transition
```

O foco não é quantidade de serviços Azure.

O foco é demonstrar:

```text
engenharia
processo
segurança
automação
governança
Git
CI/CD
Terraform
Azure
```

---

# 31. Referências técnicas prioritárias

Ao tomar decisões, priorizar documentação oficial:

- HashiCorp Terraform Documentation
- HashiCorp AzureRM Backend Documentation
- Terraform AzureRM Provider Registry
- Microsoft Learn
- GitHub Actions Documentation

Para Remote State:

```text
Terraform azurerm backend
Azure Blob Storage
Microsoft Entra ID authentication
state locking
```

Para CI/CD:

```text
GitHub Actions
Azure Workload Identity Federation
OIDC
Terraform plan on Pull Request
controlled apply
```

Não seguir tutoriais antigos que dependam de `client_secret` permanente quando OIDC puder ser utilizado.

---

# 32. Regra final

O objetivo deste repositório não é parecer complexo.

O objetivo é parecer **bem operado**.

Uma arquitetura pequena com:

```text
remote state
OIDC
PR review
CI/CD
security scanning
state isolation
version control
good documentation
cost awareness
```

é mais valiosa para este projeto do que adicionar dezenas de serviços Azure.
