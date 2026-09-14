# ==============================================================================
# OUTPUTS DO PROJETO
# ==============================================================================

# Resource Group
output "resource_group_name" {
  description = "Nome do Resource Group criado"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID do Resource Group"
  value       = azurerm_resource_group.main.id
}

output "resource_group_location" {
  description = "Localização do Resource Group"
  value       = azurerm_resource_group.main.location
}

# Network
output "vnet_id" {
  description = "ID da Virtual Network"
  value       = module.network.vnet_id
}

output "vnet_name" {
  description = "Nome da Virtual Network"
  value       = module.network.vnet_name
}

output "subnet_ids" {
  description = "IDs das Subnets criadas"
  value       = module.network.subnet_ids
}

# Security
output "key_vault_id" {
  description = "ID do Key Vault"
  value       = module.security.key_vault_id
}

output "key_vault_uri" {
  description = "URI do Key Vault"
  value       = module.security.key_vault_uri
}

# Storage
output "storage_account_name" {
  description = "Nome da Storage Account"
  value       = module.storage.storage_account_name
}

output "storage_account_primary_blob_endpoint" {
  description = "Endpoint primário do Blob Storage"
  value       = module.storage.primary_blob_endpoint
}

# Compute
output "vm_ids" {
  description = "IDs das Virtual Machines criadas"
  value       = module.compute.vm_ids
}

output "vm_private_ips" {
  description = "IPs privados das Virtual Machines"
  value       = module.compute.vm_private_ips
}

output "admin_password_secret_id" {
  description = "Obsoleto: sempre null; VMs usam chave SSH"
  value       = module.compute.admin_password_secret_id
  sensitive   = true
}

# Summary
output "common_tags" {
  description = "Tags efetivas estáveis, compartilhadas pelos recursos que suportam tags."
  value       = local.common_tags
}

output "deployment_summary" {
  description = "Resumo do deployment"
  value = {
    environment         = var.environment
    project             = var.project_name
    location            = var.location
    resource_group      = azurerm_resource_group.main.name
    vnet_address_space  = var.vnet_address_space
    vm_count            = var.vm_count
    vm_size             = var.vm_size
    storage_replication = var.storage_replication_type
  }
}
