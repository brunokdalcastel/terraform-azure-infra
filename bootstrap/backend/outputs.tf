output "backend_coordinates" {
  description = "Coordenadas não secretas para futura configuração do backend; não ativa nem migra state."
  value = {
    resource_group_name  = azurerm_resource_group.state.name
    storage_account_name = azurerm_storage_account.state.name
    container_name       = azurerm_storage_container.state.name
    use_azuread_auth     = true
  }
}

output "storage_account_id" {
  description = "Escopo para revisão futura das permissões de acesso ao state."
  value       = azurerm_storage_account.state.id
}
