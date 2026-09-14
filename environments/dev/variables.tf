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
  type    = string
  default = "dev"
}

variable "location" {
  type    = string
  default = "swedencentral"
}

variable "vm_count" {
  description = "Quantidade de VMs de teste: 0 desabilita compute; DEV permite no máximo 1."
  type        = number
  default     = 0
  nullable    = false

  validation {
    condition     = contains([0, 1], var.vm_count)
    error_message = "DEV aceita apenas vm_count = 0 ou 1."
  }
}

variable "vm_size" {
  description = "SKU candidato para testes; confirmar preço e disponibilidade antes da execução aprovada."
  type        = string
  default     = "Standard_B1s"
  nullable    = false

  validation {
    condition     = contains(["Standard_B1s", "Standard_B2s"], var.vm_size)
    error_message = "DEV permite apenas Standard_B1s ou Standard_B2s; outros SKUs exigem revisão da política em PR."
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
    error_message = "DEV permite somente Storage Standard."
  }
}

variable "storage_replication_type" {
  type     = string
  default  = "LRS"
  nullable = false
  validation {
    condition     = var.storage_replication_type == "LRS"
    error_message = "DEV permite somente replicação LRS."
  }
}

variable "key_vault_allowed_ipv4_addresses" {
  description = "IPv4 individuais aprovados para Key Vault; vazio por padrão."
  type        = set(string)
  default     = []
  nullable    = false
}

variable "admin_ssh_public_key" {
  description = "Chave pública RSA OpenSSH para a futura execução aprovada; nunca chave privada."
  type        = string
  default     = ""
  nullable    = false
}

variable "admin_source_cidrs" {
  description = "Hosts administrativos privados /32, alcançáveis por rota privada a revisar."
  type        = set(string)
  default     = []
  nullable    = false
}
