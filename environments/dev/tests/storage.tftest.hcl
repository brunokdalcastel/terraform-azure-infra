# Shared module tested without real provider access.
mock_provider "azurerm" {}
mock_provider "random" {}

variables {
  resource_group_name      = "rg-storage-test"
  location                 = "swedencentral"
  name_prefix              = "test-dev"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  subnet_ids               = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/app"]
  tags                     = {}
}

run "restricted_defaults" {
  command = plan
  module { source = "../../modules/storage" }
  assert {
    condition = (
      !azurerm_storage_account.main.shared_access_key_enabled &&
      azurerm_storage_account.main.default_to_oauth_authentication &&
      azurerm_storage_account.main.https_traffic_only_enabled &&
      azurerm_storage_account.main.min_tls_version == "TLS1_2" &&
      !azurerm_storage_account.main.allow_nested_items_to_be_public
    )
    error_message = "Storage deve exigir autenticação Entra ID e transporte seguro."
  }
  assert {
    condition = (
      azurerm_storage_account.main.network_rules[0].default_action == "Deny" &&
      azurerm_storage_account.main.network_rules[0].bypass == toset(["None"]) &&
      length(azurerm_storage_account.main.network_rules[0].ip_rules) == 0 &&
      azurerm_storage_account.main.network_rules[0].virtual_network_subnet_ids == toset(var.subnet_ids)
    )
    error_message = "Somente a subnet explicitamente fornecida deve ser permitida por padrão."
  }
  assert {
    condition = alltrue([
      for container in [azurerm_storage_container.data, azurerm_storage_container.logs, azurerm_storage_container.backups] :
      container.container_access_type == "private"
    ])
    error_message = "Os três containers devem permanecer privados."
  }
}

run "explicit_operator_ip" {
  command = plan
  module { source = "../../modules/storage" }
  variables { allowed_ipv4_addresses = ["203.0.113.10"] }
  assert {
    condition     = azurerm_storage_account.main.network_rules[0].ip_rules == toset(["203.0.113.10"])
    error_message = "Somente os IPs fornecidos devem ser incluídos."
  }
}

run "reject_open_cidr" {
  command = plan
  module { source = "../../modules/storage" }
  variables { allowed_ipv4_addresses = ["0.0.0.0/0"] }
  expect_failures = [var.allowed_ipv4_addresses]
}
