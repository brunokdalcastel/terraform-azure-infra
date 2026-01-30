# Terraform Azure Infrastructure

![Terraform](https://img.shields.io/badge/Terraform-≥1.5.0-purple?logo=terraform)
![Azure](https://img.shields.io/badge/Azure-Free%20Tier%20Ready-blue?logo=microsoft-azure)
![License](https://img.shields.io/badge/License-MIT-green)

Infraestrutura como Código (IaC) para provisionar uma arquitetura completa e segura na Azure, otimizada para **Free Tier**.

## Recursos Provisionados

Este projeto cria uma infraestrutura de 3 camadas (Web, App, Data) com os seguintes recursos:

| Categoria | Recursos |
|-----------|----------|
| **Rede** | Virtual Network, 3 Subnets, 3 Network Security Groups |
| **Compute** | Virtual Machines Linux (Ubuntu 22.04) com Docker pré-instalado |
| **Storage** | Storage Account com 3 containers (data, logs, backups) |
| **Segurança** | Azure Key Vault para armazenamento de segredos |

## Arquitetura

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  RESOURCE GROUP (rg-{projeto}-{ambiente})                                   │
│                                                                             │
│  ┌─────────────────┐     ┌────────────────────────────────────────────────┐ │
│  │                 │     │  VIRTUAL NETWORK (10.0.0.0/16)                 │ │
│  │   KEY VAULT     │     │                                                │ │
│  │                 │     │  ┌──────────────────────────────────────────┐  │ │
│  │  ┌───────────┐  │     │  │  SUBNET WEB (10.0.1.0/24)                │  │ │
│  │  │ Segredos  │──┼────▶│  │  ┌────────────────────────────────────┐  │  │ │
│  │  │ (senhas)  │  │     │  │  │  VM + Docker         [NSG: 80,443] │  │  │ │
│  │  └───────────┘  │     │  │  └────────────────────────────────────┘  │  │ │
│  └─────────────────┘     │  └──────────────────────────────────────────┘  │ │
│                          │                                                │ │
│  ┌─────────────────┐     │  ┌──────────────────────────────────────────┐  │ │
│  │                 │     │  │  SUBNET APP (10.0.2.0/24)                │  │ │
│  │ STORAGE ACCOUNT │     │  │  ┌────────────────────────────────────┐  │  │ │
│  │                 │     │  │  │  VM + Docker      [NSG: 8080,8443] │  │  │ │
│  │  ├─ data       │◀────┼──│  └────────────────────────────────────┘  │  │ │
│  │  ├─ logs       │     │  └──────────────────────────────────────────┘  │ │
│  │  └─ backups    │     │                                                │ │
│  └─────────────────┘     │  ┌──────────────────────────────────────────┐  │ │
│                          │  │  SUBNET DATA (10.0.3.0/24)               │  │ │
│                          │  │  [NSG: 1433,3306,5432 - apenas interno]  │  │ │
│                          │  └──────────────────────────────────────────┘  │ │
│                          └────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Estrutura do Projeto

```
terraform-azure-infra/
│
├── environments/                    # Configurações por ambiente
│   └── dev/
│       ├── main.tf                  # Configuração principal e providers
│       ├── variables.tf             # Declaração de variáveis
│       ├── outputs.tf               # Outputs do ambiente
│       └── terraform.tfvars.example # Template de configuração
│
├── modules/                         # Módulos reutilizáveis
│   ├── app-infrastructure/          # Módulo orquestrador
│   │   ├── main.tf                  # Chama os outros módulos
│   │   ├── variables.tf             # Variáveis de entrada
│   │   └── outputs.tf               # Outputs consolidados
│   │
│   ├── network/                     # Recursos de rede
│   │   ├── main.tf                  # VNet, Subnets, NSGs
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── compute/                     # Máquinas virtuais
│   │   ├── main.tf                  # VMs, NICs, scripts
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── storage/                     # Armazenamento
│   │   ├── main.tf                  # Storage Account, containers
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── security/                    # Segurança
│       ├── main.tf                  # Key Vault
│       ├── variables.tf
│       └── outputs.tf
│
├── .github/workflows/               # CI/CD
│   └── terraform.yml                # Pipeline de validação
│
├── .gitignore
├── .editorconfig
├── LICENSE
├── CONTRIBUTING.md
└── README.md
```

## Pré-requisitos

| Ferramenta | Versão Mínima | Instalação |
|------------|---------------|------------|
| Terraform | 1.5.0+ | [Download](https://www.terraform.io/downloads) |
| Azure CLI | 2.50.0+ | [Download](https://docs.microsoft.com/cli/azure/install-azure-cli) |
| Git | 2.0+ | [Download](https://git-scm.com/downloads) |

**Conta Azure:** Você precisa de uma conta Azure com permissões de **Contributor** no nível de subscription.

## Quick Start

### 1. Clone o Repositório

```bash
git clone https://github.com/seu-usuario/terraform-azure-infra.git
cd terraform-azure-infra
```

### 2. Autentique na Azure

```bash
# Login interativo
az login

# Verifique a subscription ativa
az account show

# (Opcional) Mude para outra subscription
az account set --subscription "SUBSCRIPTION_ID"
```

### 3. Configure as Variáveis

```bash
cd environments/dev

# Copie o template
cp terraform.tfvars.example terraform.tfvars

# Edite com suas configurações
# Mínimo necessário: project_name e owner
```

**Exemplo de `terraform.tfvars`:**
```hcl
project_name             = "meuapp"
environment              = "dev"
location                 = "brazilsouth"
owner                    = "seu-email@exemplo.com"
vm_count                 = 1
storage_account_tier     = "Standard"
storage_replication_type = "LRS"
```

### 4. Inicialize e Aplique

```bash
# Inicializar (baixa providers e módulos)
terraform init

# Visualizar o que será criado
terraform plan

# Criar a infraestrutura
terraform apply
```

### 5. Verifique os Outputs

```bash
# Ver todos os outputs
terraform output

# Ver IPs das VMs
terraform output vm_private_ips

# Ver URI do Key Vault
terraform output key_vault_uri
```

### 6. Destruir (quando não precisar mais)

```bash
terraform destroy
```

## Variáveis

### Obrigatórias

| Variável | Descrição | Exemplo |
|----------|-----------|---------|
| `project_name` | Nome do projeto (usado em nomes de recursos) | `"meuapp"` |
| `owner` | Email do responsável | `"admin@empresa.com"` |

### Opcionais

| Variável | Descrição | Default |
|----------|-----------|---------|
| `environment` | Ambiente (dev, staging, prod) | `"dev"` |
| `location` | Região Azure | `"westus2"` |
| `vm_count` | Número de VMs | `1` |
| `vm_size` | SKU da VM | `"Standard_B1s"` |
| `admin_username` | Usuário admin das VMs | `"azureadmin"` |
| `storage_account_tier` | Tier do storage | `"Standard"` |
| `storage_replication_type` | Tipo de replicação | `"LRS"` |
| `vnet_address_space` | CIDR da VNet | `["10.0.0.0/16"]` |
| `common_tags` | Tags adicionais | `{}` |

## Outputs

| Output | Descrição |
|--------|-----------|
| `resource_group_name` | Nome do Resource Group |
| `vnet_id` | ID da Virtual Network |
| `vnet_name` | Nome da Virtual Network |
| `subnet_ids` | Map com IDs das subnets (web, app, data) |
| `key_vault_id` | ID do Key Vault |
| `key_vault_uri` | URI para acessar o Key Vault |
| `storage_account_name` | Nome da Storage Account |
| `storage_blob_endpoint` | Endpoint do Blob Storage |
| `vm_ids` | Lista de IDs das VMs |
| `vm_private_ips` | Lista de IPs privados das VMs |
| `deployment_summary` | Resumo completo do deployment |

## Segurança

Este projeto implementa as seguintes práticas de segurança:

| Prática | Implementação |
|---------|---------------|
| **Gestão de Segredos** | Senhas geradas automaticamente e armazenadas no Key Vault |
| **Segmentação de Rede** | 3 subnets isoladas com NSGs específicos |
| **Sem IP Público** | VMs acessíveis apenas via rede privada (usar Azure Bastion) |
| **HTTPS Obrigatório** | Storage Account aceita apenas conexões HTTPS |
| **TLS 1.2** | Versão mínima de TLS para Storage Account |
| **Service Endpoints** | Restrição de acesso a Storage e Key Vault por subnet |

### Regras de NSG por Camada

| Subnet | Portas Permitidas | Origem |
|--------|-------------------|--------|
| Web | 80, 443, 22 | Internet (HTTP/S), VNet (SSH) |
| App | 8080, 8443, 22 | Subnet Web, VNet (SSH) |
| Data | 1433, 3306, 5432 | Subnet App apenas |


## CI/CD

O projeto inclui um workflow GitHub Actions (`.github/workflows/terraform.yml`) que executa:

- **terraform fmt** - Verifica formatação do código
- **terraform validate** - Valida sintaxe e configuração
- **Checkov** - Análise de segurança da infraestrutura
- **Comentários em PRs** - Feedback automático em Pull Requests

## Ambientes

O projeto suporta múltiplos ambientes. Cada ambiente pode ter configurações diferentes:

| Ambiente | VM Size | VM Count | Storage | VNet CIDR |
|----------|---------|----------|---------|-----------|
| Dev | B1s | 1 | LRS | 10.0.0.0/16 |
| Staging | B2ms | 2 | GRS | 10.1.0.0/16 |
| Prod | D2s_v3 | 4 | ZRS | 10.2.0.0/16 |

## Troubleshooting

### Erro: "The subscription is not registered to use namespace 'Microsoft.X'"

```bash
az provider register --namespace Microsoft.Compute
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.Storage
az provider register --namespace Microsoft.KeyVault
```

### Erro: "Quota exceeded" ou "Not enough capacity"

Mude a região no `terraform.tfvars`:
```hcl
location = "eastus2"  # ou outra região com capacidade
```

### Erro: "AuthorizationFailed"

Verifique suas permissões:
```bash
az role assignment list --assignee $(az account show --query user.name -o tsv)
```

### Como acessar as VMs?

As VMs não têm IP público por segurança. Use o Azure Bastion:
```bash
az network bastion ssh --name "bastion-name" --resource-group "rg-name" --target-resource-id "/subscriptions/.../virtualMachines/vm-name" --auth-type password --username azureadmin
```

### Como recuperar a senha da VM?

```bash
# A senha está no Key Vault
az keyvault secret show --vault-name "kv-meuapp-xxxx" --name "vm-admin-password" --query value -o tsv
```

## Contribuindo

Veja [CONTRIBUTING.md](CONTRIBUTING.md) para diretrizes de contribuição.

## Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## Referências

- [Azure Provider - Terraform Registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [Azure Architecture Center](https://docs.microsoft.com/azure/architecture/)
- [Azure Free Tier FAQ](https://azure.microsoft.com/free/free-account-faq/)
- [Azure Naming Conventions](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
