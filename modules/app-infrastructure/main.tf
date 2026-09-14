# ==============================================================================
# TERRAFORM AZURE INFRASTRUCTURE (MODULE)
# ==============================================================================

# Dados do cliente Azure atual
data "azurerm_client_config" "current" {}

# Tags locais padronizadas
locals {
  common_tags = merge(
    { for key, value in var.common_tags : key => value
      if !contains(["environment", "project", "managedby", "owner", "createdat"], lower(key))
    },
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
      Owner       = var.owner
    }
  )

  # Naming convention
  name_prefix = "${var.project_name}-${var.environment}"
}

# ==============================================================================
# RESOURCE GROUP
# ==============================================================================

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = local.common_tags
}

# ==============================================================================
# MÓDULO DE REDE
# ==============================================================================

module "network" {
  source = "../network"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  name_prefix         = local.name_prefix
  vnet_address_space  = var.vnet_address_space
  subnets             = var.subnets
  tags                = local.common_tags
}

# ==============================================================================
# MÓDULO DE SEGURANÇA (KEY VAULT)
# ==============================================================================

module "security" {
  source = "../security"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  name_prefix         = local.name_prefix
  environment         = var.environment
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
  subnet_ids          = [module.network.subnet_ids["app"]]
  tags                = local.common_tags

  depends_on = [module.network]
}

# ==============================================================================
# MÓDULO DE STORAGE
# ==============================================================================

module "storage" {
  source = "../storage"

  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  name_prefix              = local.name_prefix
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_replication_type
  subnet_ids               = [module.network.subnet_ids["data"]]
  tags                     = local.common_tags

  depends_on = [module.network]
}

# ==============================================================================
# MÓDULO DE COMPUTE
# ==============================================================================

module "compute" {
  source = "../compute"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  name_prefix         = local.name_prefix
  vm_count            = var.vm_count
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  vm_image            = var.vm_image
  subnet_id           = module.network.subnet_ids["app"]
  key_vault_id        = module.security.key_vault_id
  tags                = local.common_tags

  depends_on = [module.network, module.security]
}
