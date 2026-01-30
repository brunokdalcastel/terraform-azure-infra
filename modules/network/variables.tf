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

variable "vnet_address_space" {
  description = "Address space da VNet"
  type        = list(string)
}

variable "subnets" {
  description = "Configuração das subnets"
  type = map(object({
    address_prefixes  = list(string)
    service_endpoints = list(string)
  }))
}

variable "tags" {
  description = "Tags dos recursos"
  type        = map(string)
}
