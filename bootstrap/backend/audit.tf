resource "azurerm_monitor_diagnostic_setting" "blob_audit" {
  count = var.audit_workspace_id == null ? 0 : 1

  name                           = "blob-audit"
  target_resource_id             = "${azurerm_storage_account.state.id}/blobServices/default"
  log_analytics_workspace_id     = var.audit_workspace_id
  log_analytics_destination_type = "Dedicated"

  dynamic "enabled_log" {
    for_each = toset(["StorageRead", "StorageWrite", "StorageDelete"])
    content {
      category = enabled_log.value
    }
  }
}
