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

variable "environment" {
  description = "Ambiente de deploy (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "tenant_id" {
  description = "Tenant ID do Azure AD"
  type        = string
}

variable "subnet_ids" {
  description = "IDs das subnets permitidas"
  type        = list(string)
}

variable "tags" {
  description = "Tags dos recursos"
  type        = map(string)
}

variable "allowed_ipv4_addresses" {
  description = "IPv4 individuais aprovados para Key Vault; vazio por padrão."
  type        = set(string)
  default     = []
  nullable    = false
  validation {
    condition     = alltrue([for address in var.allowed_ipv4_addresses : can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$", address)) && can(cidrnetmask("${address}/32"))])
    error_message = "Informe IPv4 individuais; não são aceitos CIDR ou IPv6."
  }
}
