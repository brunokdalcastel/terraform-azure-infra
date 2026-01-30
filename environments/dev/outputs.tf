# ==============================================================================
# OUTPUTS DO AMBIENTE DEV
# ==============================================================================

# Resource Group
output "resource_group_name" {
  description = "Nome do Resource Group criado"
  value       = module.app_infrastructure.resource_group_name
}

output "resource_group_id" {
  description = "ID do Resource Group"
  value       = module.app_infrastructure.resource_group_id
}

output "resource_group_location" {
  description = "Localização do Resource Group"
  value       = module.app_infrastructure.resource_group_location
}

# Network
output "vnet_id" {
  description = "ID da Virtual Network"
  value       = module.app_infrastructure.vnet_id
}

output "vnet_name" {
  description = "Nome da Virtual Network"
  value       = module.app_infrastructure.vnet_name
}

output "subnet_ids" {
  description = "IDs das Subnets criadas"
  value       = module.app_infrastructure.subnet_ids
}

# Security
output "key_vault_id" {
  description = "ID do Key Vault"
  value       = module.app_infrastructure.key_vault_id
}

output "key_vault_uri" {
  description = "URI do Key Vault"
  value       = module.app_infrastructure.key_vault_uri
  sensitive   = true
}

# Storage
output "storage_account_name" {
  description = "Nome da Storage Account"
  value       = module.app_infrastructure.storage_account_name
}

output "storage_blob_endpoint" {
  description = "Endpoint primário do Blob Storage"
  value       = module.app_infrastructure.storage_account_primary_blob_endpoint
}

# Compute
output "vm_ids" {
  description = "IDs das Virtual Machines criadas"
  value       = module.app_infrastructure.vm_ids
}

output "vm_private_ips" {
  description = "IPs privados das Virtual Machines"
  value       = module.app_infrastructure.vm_private_ips
}

# Summary
output "deployment_summary" {
  description = "Resumo do deployment"
  value       = module.app_infrastructure.deployment_summary
}
