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
  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  soft_delete_retention_days      = 7
  purge_protection_enabled        = var.environment == "prod" ? true : false

  # Política de acesso para o usuário atual
  access_policy {
    tenant_id = var.tenant_id
    object_id = var.object_id

    key_permissions = [
      "Get",
      "List",
      "Create",
      "Delete",
      "Update",
      "Recover",
      "Purge",
      "GetRotationPolicy",
    ]

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Recover",
      "Purge",
    ]

    certificate_permissions = [
      "Get",
      "List",
      "Create",
      "Delete",
      "Update",
    ]
  }

  # Regras de rede
  # Em prod, default_action="Deny" bloqueia acessos fora das subnets permitidas
  # Em dev/staging, "Allow" facilita o desenvolvimento e troubleshooting
  network_acls {
    default_action             = var.environment == "prod" ? "Deny" : "Allow"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = var.subnet_ids
    ip_rules                   = []
  }
}
