# Variáveis que vêm do arquivo .tfvars (environment specific)
variable "storage_allowed_ipv4_addresses" {
  description = "IPs individuais aprovados para acessar o Storage; vazio por padrão."
  type        = set(string)
  default     = []
  nullable    = false
}

variable "common_tags" {
  description = "Tags adicionais; as tags de governança do módulo têm precedência."
  type        = map(string)
  default     = {}
  nullable    = false
}


variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  sensitive   = true
}

variable "project_name" {
  type = string
}

variable "environment" {
  type     = string
  default  = "prod"
  nullable = false
  validation {
    condition     = var.environment == "prod"
    error_message = "Este root module aceita somente environment = prod. Use environments/dev para DEV."
  }
}

variable "location" {
  type    = string
  default = "swedencentral"
}

variable "vm_count" {
  description = "Quantidade de VMs de teste: 0 desabilita compute; PROD permite no máximo 1."
  type        = number
  default     = 0
  nullable    = false

  validation {
    condition     = contains([0, 1], var.vm_count)
    error_message = "PROD aceita apenas vm_count = 0 ou 1."
  }
}

variable "vm_size" {
  description = "SKU candidato para testes; confirmar preço e disponibilidade antes da execução aprovada."
  type        = string
  default     = "Standard_B1s"
  nullable    = false

  validation {
    condition     = contains(["Standard_B1s", "Standard_B2s"], var.vm_size)
    error_message = "PROD permite apenas Standard_B1s ou Standard_B2s; outros SKUs exigem revisão da política em PR."
  }
}

variable "owner" {
  type = string
}

variable "storage_account_tier" {
  type     = string
  default  = "Standard"
  nullable = false
  validation {
    condition     = var.storage_account_tier == "Standard"
    error_message = "PROD permite somente Storage Standard."
  }
}

variable "storage_replication_type" {
  type     = string
  default  = "LRS"
  nullable = false
  validation {
    condition     = var.storage_replication_type == "LRS"
    error_message = "PROD permite somente replicação LRS."
  }
}
