output "storage_account_id" {
  description = "ID da Storage Account"
  value       = azurerm_storage_account.main.id
}

output "storage_account_name" {
  description = "Nome da Storage Account"
  value       = azurerm_storage_account.main.name
}

output "primary_blob_endpoint" {
  description = "Endpoint primário do Blob"
  value       = azurerm_storage_account.main.primary_blob_endpoint
}

output "container_names" {
  description = "Nomes dos containers criados"
  value = [
    azurerm_storage_container.data.name,
    azurerm_storage_container.logs.name,
    azurerm_storage_container.backups.name,
  ]
}
