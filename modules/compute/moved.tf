# Preserve resource identity for existing consumers that keep compute enabled.
# No state operation is executed until a separately approved real deployment.
moved {
  from = random_password.admin_password
  to   = random_password.admin_password[0]
}

moved {
  from = azurerm_key_vault_secret.admin_password
  to   = azurerm_key_vault_secret.admin_password[0]
}
