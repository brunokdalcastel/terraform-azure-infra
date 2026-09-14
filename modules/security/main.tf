# ==============================================================================
# MÓDULO DE SEGURANÇA - KEY VAULT
# ==============================================================================

# Variáveis definidas em variables.tf

# ==============================================================================
# RANDOM SUFFIX PARA NOME ÚNICO
# ==============================================================================

resource "random_string" "kv_suffix" {
  length  = 4
  special = false
  upper   = false
}

# ==============================================================================
# KEY VAULT
# ==============================================================================

resource "azurerm_key_vault" "main" {
  name                = "kv-${replace(var.name_prefix, "-", "")}${random_string.kv_suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  sku_name            = "standard"
  tags                = var.tags

  # Configurações de segurança
  enabled_for_deployment          = false
  enabled_for_disk_encryption     = false
  enabled_for_template_deployment = false
  soft_delete_retention_days      = 7
  purge_protection_enabled        = var.environment == "prod" ? true : false

  # RBAC is prepared here; role assignments require a separately approved design.
  enable_rbac_authorization = true
  access_policy             = []

  # Regras de rede
  # Allow only explicitly reviewed subnets and operator addresses.

  network_acls {
    default_action             = "Deny"
    bypass                     = "None"
    virtual_network_subnet_ids = var.subnet_ids
    ip_rules                   = var.allowed_ipv4_addresses
  }
}
