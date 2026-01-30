# ==============================================================================
# VARIÁVEIS GERAIS
# ==============================================================================

variable "project_name" {
  description = "Nome do projeto (usado em naming conventions)"
  type        = string
}

variable "environment" {
  description = "Ambiente de deploy (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment deve ser: dev, staging ou prod."
  }
}

variable "location" {
  description = "Região Azure para deploy dos recursos"
  type        = string
  default     = "westus2" # Região com boa capacidade para Free Tier
}

variable "owner" {
  description = "Email do responsável pelo projeto"
  type        = string
  default     = "admin@empresa.com"
}

# ==============================================================================
# VARIÁVEIS DE REDE
# ==============================================================================

variable "vnet_address_space" {
  description = "Address space da Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "Configuração das subnets"
  type = map(object({
    address_prefixes  = list(string)
    service_endpoints = list(string)
  }))
  default = {
    web = {
      address_prefixes  = ["10.0.1.0/24"]
      service_endpoints = ["Microsoft.Web"]
    }
    app = {
      address_prefixes  = ["10.0.2.0/24"]
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    }
    data = {
      address_prefixes  = ["10.0.3.0/24"]
      service_endpoints = ["Microsoft.Storage", "Microsoft.Sql"]
    }
  }
}

# ==============================================================================
# VARIÁVEIS DE COMPUTE
# ==============================================================================

variable "vm_size" {
  description = "Tamanho das Virtual Machines"
  type        = string
  default     = "Standard_D2s_v3" # SKU disponível em swedencentral
}

variable "vm_count" {
  description = "Número de VMs a serem criadas"
  type        = number
  default     = 1 # 1 VM para Free Tier
}

variable "admin_username" {
  description = "Username do administrador das VMs"
  type        = string
  default     = "azureadmin"
}

variable "vm_image" {
  description = "Imagem do sistema operacional das VMs"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

# ==============================================================================
# VARIÁVEIS DE STORAGE
# ==============================================================================

variable "storage_account_tier" {
  description = "Tier da Storage Account"
  type        = string
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Tipo de replicação da Storage Account"
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS"], var.storage_replication_type)
    error_message = "Replication type deve ser: LRS, GRS, RAGRS ou ZRS."
  }
}

# ==============================================================================
# TAGS COMUNS
# ==============================================================================

variable "common_tags" {
  description = "Tags comuns aplicadas a todos os recursos"
  type        = map(string)
  default     = {}
}
