mock_provider "azurerm" {}
mock_provider "random" {}

variables {
  resource_group_name = "rg-kv-test"
  location            = "swedencentral"
  name_prefix         = "test-dev"
  tenant_id           = "00000000-0000-0000-0000-000000000000"
  subnet_ids          = []
  tags                = {}
}

run "rbac_and_closed_network" {
  command = plan
  module { source = "../../modules/security" }
  assert {
    condition     = azurerm_key_vault.main.enable_rbac_authorization && length(azurerm_key_vault.main.access_policy) == 0
    error_message = "RBAC não deve manter access policies legadas."
  }
  assert {
    condition     = azurerm_key_vault.main.network_acls[0].default_action == "Deny" && azurerm_key_vault.main.network_acls[0].bypass == "None" && length(azurerm_key_vault.main.network_acls[0].ip_rules) == 0
    error_message = "Key Vault deve bloquear origens não explícitas também no DEV."
  }
  assert {
    condition     = !azurerm_key_vault.main.enabled_for_deployment && !azurerm_key_vault.main.enabled_for_disk_encryption && !azurerm_key_vault.main.enabled_for_template_deployment
    error_message = "Integrações legadas não utilizadas devem estar desativadas."
  }
}

run "prod_retains_purge_protection" {
  command = plan
  module { source = "../../modules/security" }
  variables { environment = "prod" }
  assert {
    condition     = azurerm_key_vault.main.purge_protection_enabled && azurerm_key_vault.main.soft_delete_retention_days == 7
    error_message = "PROD deve preservar proteção contra purge e retenção."
  }
}

run "reject_open_cidr" {
  command = plan
  module { source = "../../modules/security" }
  variables { allowed_ipv4_addresses = ["0.0.0.0/0"] }
  expect_failures = [var.allowed_ipv4_addresses]
}
