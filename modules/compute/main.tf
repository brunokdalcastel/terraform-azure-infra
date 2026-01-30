# ==============================================================================
# MÓDULO DE COMPUTE - VIRTUAL MACHINES
# ==============================================================================

# Variáveis definidas em variables.tf

# ==============================================================================
# SENHA ALEATÓRIA
# ==============================================================================

resource "random_password" "admin_password" {
  length           = 20
  special          = true
  override_special = "!@#$%&*()-_=+[]{}|"
  min_lower        = 2
  min_upper        = 2
  min_numeric      = 2
  min_special      = 2
}

# ==============================================================================
# ARMAZENA SENHA NO KEY VAULT
# ==============================================================================

resource "azurerm_key_vault_secret" "admin_password" {
  name         = "vm-admin-password"
  value        = random_password.admin_password.result
  key_vault_id = var.key_vault_id

  tags = var.tags
}

# ==============================================================================
# NETWORK INTERFACES
# ==============================================================================

resource "azurerm_network_interface" "main" {
  count = var.vm_count

  name                = "nic-vm${count.index + 1}-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# ==============================================================================
# VIRTUAL MACHINES
# ==============================================================================

resource "azurerm_linux_virtual_machine" "main" {
  count = var.vm_count

  name                = "vm-${count.index + 1}-${var.name_prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  tags                = var.tags

  admin_username                  = var.admin_username
  admin_password                  = random_password.admin_password.result
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.main[count.index].id
  ]

  os_disk {
    name                 = "osdisk-vm${count.index + 1}-${var.name_prefix}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = var.vm_image.publisher
    offer     = var.vm_image.offer
    sku       = var.vm_image.sku
    version   = var.vm_image.version
  }

  # Boot diagnostics (opcional)
  boot_diagnostics {
    storage_account_uri = null # Usa managed storage
  }

  # Identity para acesso a outros recursos Azure
  identity {
    type = "SystemAssigned"
  }

  # Custom data para inicialização (exemplo: instalar Docker)
  custom_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y ca-certificates curl gnupg
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    usermod -aG docker ${var.admin_username}
    echo "VM ${count.index + 1} initialized successfully!" > /var/log/init-complete.log
  EOF
  )
}

# Variáveis e Outputs movidos para arquivos separados
