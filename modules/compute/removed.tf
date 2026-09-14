# Legacy credentials must be reviewed and retired separately, never deleted implicitly.
# These declarations do not execute any state operation during offline validation.
removed {
  from = random_password.admin_password
  lifecycle { destroy = false }
}

removed {
  from = azurerm_key_vault_secret.admin_password
  lifecycle { destroy = false }
}
