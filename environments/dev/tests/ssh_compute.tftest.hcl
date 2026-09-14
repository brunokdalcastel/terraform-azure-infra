mock_provider "azurerm" {}
mock_provider "random" {}
variables {
  resource_group_name = "rg-test"
  location            = "swedencentral"
  name_prefix         = "test-dev"
  vm_count            = 0
  vm_size             = "Standard_B1s"
  admin_username      = "azureadmin"
  subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/app"
  tags                = {}
  vm_image = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}
run "ssh_only_private_vm" {
  command = plan
  module { source = "../../modules/compute" }
  variables {
    vm_count             = 1
    admin_ssh_public_key = trimspace(file("tests/mock_rsa.pub"))
  }
  assert {
    condition     = azurerm_linux_virtual_machine.main[0].disable_password_authentication && azurerm_linux_virtual_machine.main[0].admin_password == null && one(azurerm_linux_virtual_machine.main[0].admin_ssh_key).public_key == var.admin_ssh_public_key
    error_message = "VM deve usar somente a chave pública fornecida."
  }
  assert {
    condition     = azurerm_network_interface.main[0].ip_configuration[0].public_ip_address_id == null && output.admin_password_secret_id == null
    error_message = "Compute não deve criar endpoint público ou secret de senha."
  }
}
run "missing_public_key" {
  command = plan
  module { source = "../../modules/compute" }
  variables { vm_count = 1 }
  expect_failures = [var.admin_ssh_public_key]
}
