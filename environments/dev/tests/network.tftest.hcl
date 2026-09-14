# Exercise the shared network module directly with a different address space.
# All resources are mocked and all runs are plans; no Azure calls.
mock_provider "azurerm" {}

run "explicit_layer_boundaries" {
  command = plan
  module {
    source = "../../modules/network"
  }
  variables {
    resource_group_name = "rg-network-test"
    location            = "swedencentral"
    name_prefix         = "network-test"
    vnet_address_space  = ["10.20.0.0/16"]
    tags                = {}
    subnets = {
      web = {
        address_prefixes  = ["10.20.1.0/24"]
        service_endpoints = []
      }
      app = {
        address_prefixes  = ["10.20.2.0/24"]
        service_endpoints = []
      }
      data = {
        address_prefixes  = ["10.20.3.0/24"]
        service_endpoints = []
      }
    }
  }
  assert {
    condition = alltrue([
      for nsg in [azurerm_network_security_group.web, azurerm_network_security_group.app, azurerm_network_security_group.data] :
      length([for rule in nsg.security_rule : rule if
        rule.name == "DenyAllInbound" && rule.priority == 4096 &&
        rule.direction == "Inbound" && rule.access == "Deny" &&
        rule.protocol == "*" && rule.source_address_prefix == "*" &&
        rule.destination_address_prefix == "*" &&
        rule.source_port_range == "*" && rule.destination_port_range == "*"
      ]) == 1
    ])
    error_message = "Cada NSG deve bloquear entradas restantes antes das permissões padrão do Azure."
  }
  assert {
    condition = (
      length(azurerm_network_security_group.app.security_rule) == 2 &&
      length([for rule in azurerm_network_security_group.app.security_rule : rule if rule.access == "Allow"]) == 1 &&
      alltrue([for rule in azurerm_network_security_group.app.security_rule :
        rule.access != "Allow" || (
          rule.source_address_prefixes == toset(["10.20.1.0/24"]) &&
          rule.destination_address_prefixes == toset(["10.20.2.0/24"]) &&
          rule.destination_port_ranges == toset(["8080", "8443"]) &&
          rule.direction == "Inbound" && rule.protocol == "Tcp" && rule.priority < 4096
        )
      ])
    )
    error_message = "App deve aceitar somente TCP 8080/8443 da subnet Web configurada."
  }
  assert {
    condition = (
      length(azurerm_network_security_group.data.security_rule) == 2 &&
      length([for rule in azurerm_network_security_group.data.security_rule : rule if rule.access == "Allow"]) == 1 &&
      alltrue([for rule in azurerm_network_security_group.data.security_rule :
        rule.access != "Allow" || (
          rule.source_address_prefixes == toset(["10.20.2.0/24"]) &&
          rule.destination_address_prefixes == toset(["10.20.3.0/24"]) &&
          rule.destination_port_ranges == toset(["1433", "3306", "5432"]) &&
          rule.direction == "Inbound" && rule.protocol == "Tcp" && rule.priority < 4096
        )
      ])
    )
    error_message = "Data deve aceitar somente portas de dados da subnet App configurada."
  }
  assert {
    condition = (
      length(azurerm_network_security_group.web.security_rule) == 3 &&
      toset([for rule in azurerm_network_security_group.web.security_rule : rule.destination_port_range if rule.access == "Allow"]) == toset(["80", "443"]) &&
      alltrue([for rule in azurerm_network_security_group.web.security_rule :
        rule.access != "Allow" || (
          rule.source_address_prefix == "Internet" &&
          rule.destination_address_prefixes == toset(["10.20.1.0/24"]) &&
          rule.direction == "Inbound" && rule.protocol == "Tcp" && rule.priority < 4096
        )
      ])
    )
    error_message = "Web deve aceitar somente HTTP/HTTPS de Internet, sem SSH genérico."
  }
}
