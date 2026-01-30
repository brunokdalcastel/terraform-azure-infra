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
