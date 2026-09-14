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

variable "admin_source_cidrs" {
  description = "IPv4 privados RFC1918 /32 de hosts administrativos aprovados."
  type        = set(string)
  default     = []
  nullable    = false
  validation {
    condition = alltrue([for cidr in var.admin_source_cidrs :
      can(cidrnetmask(cidr)) &&
      can(regex("^(10\\.[0-9]+\\.[0-9]+\\.[0-9]+|192\\.168\\.[0-9]+\\.[0-9]+|172\\.(1[6-9]|2[0-9]|3[01])\\.[0-9]+\\.[0-9]+)/32$", cidr))
    ])
    error_message = "Use somente hosts IPv4 privados RFC1918 /32; redes amplas e Internet são rejeitadas."
  }
}
