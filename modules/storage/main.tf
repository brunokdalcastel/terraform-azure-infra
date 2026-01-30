# ==============================================================================
# MÓDULO DE STORAGE - STORAGE ACCOUNT
# ==============================================================================

# Variáveis definidas em variables.tf

# ==============================================================================
# RANDOM SUFFIX PARA NOME ÚNICO
# ==============================================================================

resource "random_string" "storage_suffix" {
  length  = 6
  special = false
  upper   = false
}

# ==============================================================================
# STORAGE ACCOUNT
# ==============================================================================

resource "azurerm_storage_account" "main" {
  name                = "st${replace(var.name_prefix, "-", "")}${random_string.storage_suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind             = "StorageV2"
  access_tier              = "Hot"

  # Configurações de segurança
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = true

  # Proteção contra exclusão acidental (mínimo 1 dia na v4.x)
  blob_properties {
    delete_retention_policy {
      days = 1
    }
    container_delete_retention_policy {
      days = 1
    }
    versioning_enabled = false
  }

  # Regras de rede
  network_rules {
    default_action             = "Allow" # Temporário para deploy - mude para "Deny" em produção
    bypass                     = ["AzureServices", "Logging", "Metrics"]
    virtual_network_subnet_ids = var.subnet_ids
    ip_rules                   = [] # Adicione seu IP para acesso local
  }
}

# ==============================================================================
# CONTAINERS
# ==============================================================================

resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "logs" {
  name                  = "logs"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "backups" {
  name                  = "backups"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}

# Variáveis e Outputs movidos para arquivos separados
