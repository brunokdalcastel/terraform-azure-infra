variable "subscription_id" {
  description = "Subscription de destino; preencher somente na etapa Azure aprovada."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.subscription_id))
    error_message = "subscription_id deve ser um UUID."
  }
}

variable "project_name" {
  description = "Identificador curto usado no nome do Resource Group."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,19}$", var.project_name))
    error_message = "Use 1 a 20 caracteres: letra minúscula inicial, letras, números ou hífen."
  }
}

variable "location" {
  description = "Região a confirmar antes do provisionamento aprovado."
  type        = string
  nullable    = false
  validation {
    condition     = length(trimspace(var.location)) > 0
    error_message = "Informe uma região."
  }
}

variable "owner" {
  description = "Identificador do responsável, sem informação pessoal sensível."
  type        = string
  nullable    = false
  validation {
    condition     = length(trimspace(var.owner)) > 0
    error_message = "Informe o responsável pelo backend."
  }
}

variable "storage_account_name" {
  description = "Nome globalmente único escolhido explicitamente; disponibilidade não é validada localmente."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Storage Account exige 3 a 24 caracteres, apenas letras minúsculas e números."
  }
}

variable "allowed_ipv4_addresses" {
  description = "IPs IPv4 individuais de saída aprovados. Sem CIDR; vazio bloqueia acesso aos dados."
  type        = set(string)
  default     = []
  nullable    = false
  validation {
    condition = alltrue([
      for address in var.allowed_ipv4_addresses :
      can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$", address)) && can(cidrnetmask("${address}/32"))
    ])
    error_message = "Informe IPv4 individuais válidos; intervalos CIDR e IPv6 não são aceitos."
  }
}

variable "audit_workspace_id" {
  description = "ID de Log Analytics existente e aprovado; null desabilita auditoria de blobs."
  type        = string
  default     = null
  validation {
    condition     = var.audit_workspace_id == null || can(regex("(?i)^/subscriptions/[0-9a-f-]{36}/resourceGroups/[^/]+/providers/Microsoft.OperationalInsights/workspaces/[^/]+$", var.audit_workspace_id))
    error_message = "Forneça ID completo de Log Analytics ou null."
  }
}
