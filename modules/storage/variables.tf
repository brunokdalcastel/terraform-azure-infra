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

variable "account_tier" {
  description = "Tier da Storage Account"
  type        = string
}

variable "account_replication_type" {
  description = "Tipo de replicação"
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
  description = "IPv4 individuais aprovados do executor; sem CIDR. Vazio permite somente as subnets configuradas."
  type        = set(string)
  default     = []
  nullable    = false
  validation {
    condition = alltrue([
      for address in var.allowed_ipv4_addresses :
      can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$", address)) && can(cidrnetmask("${address}/32"))
    ])
    error_message = "Informe IPv4 individuais válidos; CIDR e IPv6 não são aceitos."
  }
}
