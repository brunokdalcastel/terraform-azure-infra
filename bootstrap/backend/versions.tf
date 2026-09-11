terraform {
  required_version = ">= 1.14.3, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.14.0"
    }
  }

  # Bootstrap must exist before the application can use remote state.
  backend "local" {
    path = "terraform.tfstate"
  }
}
