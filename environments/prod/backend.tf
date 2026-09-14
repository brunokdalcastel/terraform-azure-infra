terraform {
  # Partial configuration: real coordinates are supplied only at approved initialization.
  # CI/local checks must keep -backend=false. No state has been migrated.
  backend "azurerm" {
    use_azuread_auth = true
    container_name   = "tfstate"
    key              = "prod.terraform.tfstate"
  }
}
