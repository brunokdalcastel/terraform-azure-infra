# No real provider authentication or resources. All runs are simulated plans.
mock_provider "azurerm" {}

variables {
  subscription_id      = "00000000-0000-0000-0000-000000000000"
  project_name         = "test"
  location             = "swedencentral"
  owner                = "portfolio"
  storage_account_name = "stbackendtest001"
}

run "secure_defaults" {
  command = plan
  assert {
    condition = (
      azurerm_storage_account.state.account_tier == "Standard" &&
      azurerm_storage_account.state.account_replication_type == "LRS" &&
      !azurerm_storage_account.state.shared_access_key_enabled &&
      !azurerm_storage_account.state.allow_nested_items_to_be_public &&
      azurerm_storage_account.state.https_traffic_only_enabled &&
      azurerm_storage_account.state.min_tls_version == "TLS1_2" &&
      azurerm_storage_container.state.container_access_type == "private"
    )
    error_message = "O backend deve manter Standard LRS, HTTPS/TLS 1.2, container privado e Shared Key desabilitada."
  }
  assert {
    condition = (
      azurerm_storage_account.state.network_rules[0].default_action == "Deny" &&
      length(azurerm_storage_account.state.network_rules[0].ip_rules) == 0 &&
      azurerm_storage_account.state.network_rules[0].bypass == toset(["None"])
    )
    error_message = "O default deve bloquear acesso aos dados sem exceções implícitas."
  }
  assert {
    condition = (
      azurerm_storage_account.state.blob_properties[0].versioning_enabled &&
      azurerm_storage_account.state.blob_properties[0].delete_retention_policy[0].days == 7 &&
      azurerm_storage_account.state.blob_properties[0].container_delete_retention_policy[0].days == 7
    )
    error_message = "Versionamento e retenção de exclusão de sete dias devem estar configurados."
  }
  assert {
    condition = (
      output.backend_coordinates.container_name == "tfstate" &&
      output.backend_coordinates.use_azuread_auth &&
      output.backend_coordinates.resource_group_name == "rg-test-tfstate"
    )
    error_message = "Coordenadas devem apontar para o backend independente com autenticação Entra ID."
  }
}

run "explicit_network_allowlist" {
  command = plan
  variables { allowed_ipv4_addresses = ["203.0.113.10"] }
  assert {
    condition     = azurerm_storage_account.state.network_rules[0].ip_rules == toset(["203.0.113.10"])
    error_message = "Apenas os IPs explícitos devem ser permitidos."
  }
}

run "reject_invalid_account_name" {
  command = plan
  variables { storage_account_name = "Invalid-Account" }
  expect_failures = [var.storage_account_name]
}

run "reject_open_cidr" {
  command = plan
  variables { allowed_ipv4_addresses = ["0.0.0.0/0"] }
  expect_failures = [var.allowed_ipv4_addresses]
}

run "reject_invalid_ip" {
  command = plan
  variables { allowed_ipv4_addresses = ["999.0.0.1"] }
  expect_failures = [var.allowed_ipv4_addresses]
}

run "audit_disabled_by_default" {
  command = plan

  assert {
    condition     = length(azurerm_monitor_diagnostic_setting.blob_audit) == 0
    error_message = "Sem destino aprovado, nenhum diagnóstico deve ser criado."
  }
}

run "audit_reads_writes_deletes" {
  command = plan

  variables {
    audit_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-audit/providers/Microsoft.OperationalInsights/workspaces/law-test"
  }
  override_resource {
    override_during = plan
    target          = azurerm_storage_account.state
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Storage/storageAccounts/sttest"
    }
  }
  assert {
    condition = (
      endswith(azurerm_monitor_diagnostic_setting.blob_audit[0].target_resource_id, "/blobServices/default") &&
      azurerm_monitor_diagnostic_setting.blob_audit[0].log_analytics_workspace_id == var.audit_workspace_id &&
      azurerm_monitor_diagnostic_setting.blob_audit[0].log_analytics_destination_type == "Dedicated" &&
      toset([for log in azurerm_monitor_diagnostic_setting.blob_audit[0].enabled_log : log.category]) == toset(["StorageRead", "StorageWrite", "StorageDelete"])
    )
    error_message = "Auditoria deve cobrir operações de blobs no destino explícito."
  }
}
