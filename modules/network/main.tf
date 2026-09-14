# ==============================================================================
# MÓDULO DE REDE - NETWORK
# ==============================================================================

# Variáveis definidas em variables.tf

# ==============================================================================
# VIRTUAL NETWORK
# ==============================================================================

resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

# ==============================================================================
# SUBNETS - Criadas sequencialmente para evitar race conditions do Azure
# ==============================================================================

resource "azurerm_subnet" "web" {
  name                 = "snet-web-${var.name_prefix}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.subnets["web"].address_prefixes
  service_endpoints    = var.subnets["web"].service_endpoints
}

resource "azurerm_subnet" "app" {
  name                 = "snet-app-${var.name_prefix}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.subnets["app"].address_prefixes
  service_endpoints    = var.subnets["app"].service_endpoints

  depends_on = [azurerm_subnet.web]
}

resource "azurerm_subnet" "data" {
  name                 = "snet-data-${var.name_prefix}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.subnets["data"].address_prefixes
  service_endpoints    = var.subnets["data"].service_endpoints

  depends_on = [azurerm_subnet.app]
}

# ==============================================================================
# NETWORK SECURITY GROUPS
# ==============================================================================

resource "azurerm_network_security_group" "web" {
  name                = "nsg-web-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # Regra para HTTP
  security_rule {
    name                         = "AllowHTTP"
    priority                     = 100
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    destination_port_range       = "80"
    source_address_prefix        = "Internet"
    destination_address_prefixes = var.subnets["web"].address_prefixes
  }

  # Regra para HTTPS
  security_rule {
    name                         = "AllowHTTPS"
    priority                     = 110
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    destination_port_range       = "443"
    source_address_prefix        = "Internet"
    destination_address_prefixes = var.subnets["web"].address_prefixes
  }

  # Explicit deny precedes Azure's default AllowVNetInBound.
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "app" {
  dynamic "security_rule" {
    for_each = length(var.admin_source_cidrs) > 0 ? [1] : []
    content {
      name                         = "AllowSSHFromApprovedHosts"
      priority                     = 200
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      source_port_range            = "*"
      destination_port_range       = "22"
      source_address_prefixes      = var.admin_source_cidrs
      destination_address_prefixes = var.subnets["app"].address_prefixes
    }
  }
  name                = "nsg-app-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # Regra para comunicação da subnet web
  security_rule {
    name                         = "AllowWebSubnet"
    priority                     = 100
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    destination_port_ranges      = ["8080", "8443"]
    source_address_prefixes      = var.subnets["web"].address_prefixes
    destination_address_prefixes = var.subnets["app"].address_prefixes
  }

  # Administrative access requires a separately reviewed explicit rule.
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "data" {
  name                = "nsg-data-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # Regra para comunicação da subnet app
  security_rule {
    name                         = "AllowAppSubnet"
    priority                     = 100
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    destination_port_ranges      = ["1433", "3306", "5432"]
    source_address_prefixes      = var.subnets["app"].address_prefixes
    destination_address_prefixes = var.subnets["data"].address_prefixes
  }

  # Bloqueia todo o resto
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# ==============================================================================
# ASSOCIAÇÃO NSG -> SUBNET (sequencial)
# ==============================================================================

resource "azurerm_subnet_network_security_group_association" "web" {
  subnet_id                 = azurerm_subnet.web.id
  network_security_group_id = azurerm_network_security_group.web.id

  depends_on = [azurerm_subnet.data]
}

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app.id

  depends_on = [azurerm_subnet_network_security_group_association.web]
}

resource "azurerm_subnet_network_security_group_association" "data" {
  subnet_id                 = azurerm_subnet.data.id
  network_security_group_id = azurerm_network_security_group.data.id

  depends_on = [azurerm_subnet_network_security_group_association.app]
}

# Variáveis e Outputs movidos para arquivos separados
