output "vnet_id" {
  description = "ID da Virtual Network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Nome da Virtual Network"
  value       = azurerm_virtual_network.main.name
}

output "subnet_ids" {
  description = "Map de IDs das subnets"
  value = {
    web  = azurerm_subnet.web.id
    app  = azurerm_subnet.app.id
    data = azurerm_subnet.data.id
  }
}

output "nsg_ids" {
  description = "IDs dos Network Security Groups"
  value = {
    web  = azurerm_network_security_group.web.id
    app  = azurerm_network_security_group.app.id
    data = azurerm_network_security_group.data.id
  }
}
