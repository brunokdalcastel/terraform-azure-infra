# Terraform Azure Infrastructure

Portfólio de Infrastructure as Code para Azure, com módulos Terraform e evolução
incremental por Pull Requests. O objetivo é demonstrar decisões de engenharia,
validação reproduzível, segurança e controle de custos.

**Status:** preparação e validação local. Provisionamento e testes reais no Azure
ficam para a etapa final, após criação da conta e aprovação manual do proprietário.
Merge de código não autoriza deploy.

## Implementado e planejado

| Área | Implementado no código | Próxima evolução |
| --- | --- | --- |
| Estrutura | DEV/PROD com inputs e chaves de state próprias; cinco módulos | Validar ambientes reais e isolamento de permissões |
| State | Bootstrap e backend AzureRM DEV preparados em código | Provisionar backend, migrar eventual state e validar locking |
| CI | fmt, init sem backend, validate e testes com mocks | TFLint e política de findings |
| Segurança CI | Checkov report-only | Bloqueio de violações selecionadas |
| Entrega | CI sem autenticação/deploy Azure | OIDC e execução manual aprovada |
| Governança | Prefixo e tags centralizadas | Tags estáveis, ADRs e política de custos |

Veja [PROJECT_PLAN.md](PROJECT_PLAN.md) e as regras em [AGENTS.md](AGENTS.md).

O [bootstrap do backend](bootstrap/backend/README.md) é independente da aplicação.
Seu código prepara o destino do state; nenhum Storage foi provisionado e o backend
DEV está configurado para AzureRM, sem inicialização ou migração real.
Veja a [preparação do DEV](environments/dev/README.md). A inicialização real exige
aprovação e revisão de rede e permissões.

## Arquitetura atual do código

```text
environments/dev
└── modules/app-infrastructure
    ├── Resource Group
    ├── network  → VNet, subnets Web/App/Data e NSGs
    ├── security → Key Vault; depende da rede
    ├── storage  → Storage Account e containers data/logs/backups
    └── compute  → NICs e VMs na subnet App; depende da rede e Key Vault
```

As VMs usam Ubuntu 22.04 e um script que instala Docker. Não há IP público,
aplicação Web, banco de dados, balanceador ou Bastion. Os containers são destinos
potenciais; envio de logs/backups não está implementado. Três subnets não
representam uma aplicação completa em três camadas já funcionando.

## Validação sem conta Azure

Pré-requisitos: Git, Terraform **1.14.3**, definido em
[.terraform-version](.terraform-version), e internet para baixar providers.
As constraints aceitam `>= 1.14.3, < 2.0.0`; outras versões não são automaticamente
consideradas testadas. Não é necessário Azure CLI, login ou tfvars reais:

```bash
git clone https://github.com/brunokdalcastel/terraform-azure-infra.git
cd terraform-azure-infra
terraform fmt -check -recursive
cd environments/dev
terraform init -backend=false -lockfile=readonly -input=false
terraform validate
terraform test
```

`init` instala dependências com o backend desabilitado. `validate` verifica a
configuração, mas não comprova permissões, quota, disponibilidade regional,
conectividade ou sucesso de um deploy.

`terraform test` usa providers simulados e somente planos locais. Verifica os
limites de custo sem consultar Azure ou criar recursos reais.

O lock file do DEV fixa AzureRM **4.14.0** e Random **3.6.3**. A raiz do repositório
não é um root module executável e não possui lock file. Os módulos declaram seus
requisitos; o DEV controla a seleção efetiva.

Os roots `bootstrap/backend` e `environments/prod` possuem lock files próprios e os
mesmos comandos de validação, executados separadamente. O CI testa os três roots
sem acesso Azure. Veja os limites do [PROD demonstrativo](environments/prod/README.md).

## Configuração DEV

O [exemplo](environments/dev/terraform.tfvars.example) contém placeholders para a
futura execução aprovada. Não commitar tfvars reais, state, planos ou credenciais.

| Input exposto pelo DEV | Obrigatório ou default |
| --- | --- |
| subscription_id | Obrigatório; placeholder no exemplo |
| project_name | Obrigatório |
| owner | Obrigatório |
| environment | dev |
| location | swedencentral; exemplo usa brazilsouth |
| vm_count | 0; DEV aceita somente 0 ou 1 |
| vm_size | Standard_B1s; DEV aceita B1s ou B2s |
| storage_account_tier | Standard |
| storage_replication_type | LRS |

O DEV expõe quantidade e SKU das VMs. O orquestrador ainda define usuário
`azureadmin` e VNet `10.0.0.0/16`, que não estão expostos pelo DEV.
Os outputs incluem Resource Group, VNet, subnets, Storage, Key Vault e IPs privados;
só terão valores de infraestrutura após um deploy real.

## Limitações conhecidas

- State pode conter dados sensíveis, inclusive a senha das VMs. Guardar a senha
  também no Key Vault não elimina sua presença no state.
- Storage exige HTTPS/TLS 1.2 e containers privados, mas permite rede de qualquer
  origem. Autenticação continua necessária.
- Key Vault permite rede no DEV; em PROD o módulo configura Deny. O acesso do
  futuro executor de deploy precisa ser resolvido antes dessa etapa.
- Apenas o NSG Data tem bloqueio final explícito. Web/App ainda permitem tráfego
  interno pela regra padrão da VNet. Há CIDRs fixos nas regras.
- VMs usam senha e identidade gerenciada; permissões da identidade para serviços
  não estão configuradas. O caminho de administração privada está pendente.
- A tag CreatedAt usa timestamp() e pode gerar mudanças recorrentes no plan.
- Checkov reporta findings sem bloquear. CI verde não significa ausência de
  vulnerabilidades nem comprova funcionamento no Azure.

Esses pontos serão tratados em mudanças próprias, com justificativa e validação.

## Custos e execução futura

Não há garantia de Free Tier. O default é **zero VMs**; habilitar uma VM exige
escolha explícita e revisão de preço/disponibilidade do SKU B1s ou B2s.
VMs, discos, Storage, operações de Key Vault e tráfego
devem entrar na estimativa. Benefícios e disponibilidade dependem da assinatura
e região. Nenhum recurso foi criado por esta etapa de preparação.

Zero VMs não é custo zero: Storage e Key Vault permanecem no código. Veja
[controle de custos](docs/cost-control.md), inclusive o impacto dos novos defaults
em instalações existentes e as limitações dos testes simulados.

A etapa final exigirá revisão de preços, quota, permissões, rede, backend e plano
de remoção. Toda execução Azure dependerá de aprovação manual explícita.

## Como explicar o projeto em entrevista

- **Módulos:** separar rede, compute, storage e segurança explicita dependências.
- **Reprodutibilidade:** versão de referência, constraints e lock file reduzem
  diferenças entre máquina local e CI.
- **Pull Requests:** cada mudança tem objetivo, diff e evidências de validação.
- **Tradeoffs:** migração e validação real do backend e regras permissivas são pendências identificadas.
  Remote state e OIDC só serão apresentados como concluídos após implementação
  e testes correspondentes.

## CI e contribuição

O [workflow](.github/workflows/terraform.yml) valida pushes em main/master e PRs.
Usa token com leitura de conteúdo e publica resultados no resumo da execução,
inclusive para forks. Não escreve comentários ou commits no repositório.
terraform-docs roda após push na main, sem publicar automaticamente o resultado.

Veja [CONTRIBUTING.md](CONTRIBUTING.md). Licença [MIT](LICENSE).

## Referências

- [Terraform: dados sensíveis](https://developer.hashicorp.com/terraform/language/manage-sensitive-data)
- [Terraform: lock file](https://developer.hashicorp.com/terraform/language/files/dependency-lock)
- [Azure: regras padrão de NSG](https://learn.microsoft.com/azure/virtual-network/network-security-groups-overview)
