variable "resource_group_name" {
  description = "Nome do Resource Group"
  type        = string
}

variable "location" {
  description = "Localização dos recursos"
  type        = string
}

variable "name_prefix" {
  description = "Prefixo para nomes dos recursos"
  type        = string
}

variable "vm_count" {
  description = "Número de VMs"
  type        = number
  nullable    = false
  validation {
    condition     = var.vm_count >= 0 && floor(var.vm_count) == var.vm_count
    error_message = "vm_count deve ser um inteiro não negativo."
  }
}

variable "vm_size" {
  description = "Tamanho das VMs"
  type        = string
}

variable "admin_username" {
  description = "Username do admin"
  type        = string
}

variable "vm_image" {
  description = "Imagem do SO"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}

variable "subnet_id" {
  description = "ID da subnet"
  type        = string
}

variable "key_vault_id" {
  description = "ID do Key Vault para armazenar secrets"
  type        = string
}

variable "tags" {
  description = "Tags dos recursos"
  type        = map(string)
}
