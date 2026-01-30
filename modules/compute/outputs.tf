output "vm_ids" {
  description = "IDs das Virtual Machines"
  value       = azurerm_linux_virtual_machine.main[*].id
}

output "vm_names" {
  description = "Nomes das Virtual Machines"
  value       = azurerm_linux_virtual_machine.main[*].name
}

output "vm_private_ips" {
  description = "IPs privados das VMs"
  value       = azurerm_network_interface.main[*].private_ip_address
}

output "vm_identities" {
  description = "Identities das VMs (para RBAC)"
  value       = azurerm_linux_virtual_machine.main[*].identity[0].principal_id
}

output "admin_password_secret_id" {
  description = "ID do secret da senha no Key Vault"
  value       = azurerm_key_vault_secret.admin_password.id
  sensitive   = true
}
