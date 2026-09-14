mock_provider "azurerm" {}
variables {
  resource_group_name = "rg-test"
  location            = "swedencentral"
  name_prefix         = "test-dev"
  vnet_address_space  = ["10.0.0.0/16"]
  tags                = {}
  subnets = {
    web  = { address_prefixes = ["10.0.1.0/24"], service_endpoints = [] }
    app  = { address_prefixes = ["10.0.2.0/24"], service_endpoints = [] }
    data = { address_prefixes = ["10.0.3.0/24"], service_endpoints = [] }
  }
}
run "explicit_private_host" {
  command = plan
  module { source = "../../modules/network" }
  variables { admin_source_cidrs = ["10.0.2.10/32"] }
  assert {
    condition     = length([for rule in azurerm_network_security_group.app.security_rule : rule if rule.name == "AllowSSHFromApprovedHosts" && rule.destination_port_range == "22" && rule.source_address_prefixes == toset(["10.0.2.10/32"]) && rule.destination_address_prefixes == toset(["10.0.2.0/24"]) && rule.direction == "Inbound" && rule.protocol == "Tcp" && rule.access == "Allow" && rule.priority < 4096]) == 1
    error_message = "SSH deve permitir apenas o host privado explícito para App."
  }
}
run "reject_public_host" {
  command = plan
  module { source = "../../modules/network" }
  variables { admin_source_cidrs = ["8.8.8.8/32"] }
  expect_failures = [var.admin_source_cidrs]
}
run "reject_broad_private_network" {
  command = plan
  module { source = "../../modules/network" }
  variables { admin_source_cidrs = ["10.0.0.0/16"] }
  expect_failures = [var.admin_source_cidrs]
}
