# ==============================================================================
# VARIÁVEIS GERAIS
# ==============================================================================

variable "project_name" {
  description = "Nome do projeto (usado em naming conventions)"
  type        = string
  nullable    = false
  validation {
    condition = (
      can(regex("^[a-z][a-z0-9-]{0,19}$", var.project_name)) &&
      length(replace(var.project_name, "-", "")) <= 9
    )
    error_message = "Use letra minúscula inicial, letras/números/hífens, até 20 caracteres e no máximo 9 sem hífens; o limite preserva os nomes de Storage também em staging."
  }
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
  default     = "westus2"
}

variable "owner" {
  description = "Identificador estável do responsável, sem dados pessoais sensíveis"
  type        = string
  default     = "admin@empresa.com"
  nullable    = false
  validation {
    condition     = length(trimspace(var.owner)) > 0
    error_message = "Owner não pode estar vazio."
  }
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
  default     = "Standard_B1s" # Confirmar custo e disponibilidade antes do deploy
}

variable "vm_count" {
  description = "Número de VMs a serem criadas"
  type        = number
  default     = 0
  nullable    = false
  validation {
    condition     = var.vm_count >= 0 && floor(var.vm_count) == var.vm_count
    error_message = "vm_count deve ser um inteiro não negativo."
  }
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

variable "storage_allowed_ipv4_addresses" {
  description = "IPv4 administrativos do Storage; validação no módulo storage."
  type        = set(string)
  default     = []
  nullable    = false
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
  description = "Tags adicionais. Environment, Project, ManagedBy, Owner e CreatedAt são reservadas, independentemente de maiúsculas."
  type        = map(string)
  default     = {}
  nullable    = false
}
