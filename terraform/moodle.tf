# Resource Group
resource "azurerm_resource_group" "moodle-rg" {
  name     = "moodle-rg"
  location = var.location
  tags     = merge(local.common_tags)
}

# VM Nic
resource "azurerm_network_interface" "moodle-vm-nic" {
  count               = 1
  name                = "${var.product_name}-nic-${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.moodle-rg.name
  ip_configuration {
    name                          = "vm-nic"
    private_ip_address_allocation = "Static"
  }
}

# VNet
resource "azurerm_virtual_network" "vnet" {
  address_space       = ["10.0.0.0/24"]
  location            = var.location
  name                = "vnet"
  resource_group_name = azurerm_resource_group.moodle-rg.name
}

# Subnet
resource "azurerm_subnet" "subnet" {
  address_prefixes     = ["10.0.1.0/24"]
  name                 = "subnet"
  resource_group_name  = azurerm_resource_group.moodle-rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

# Public IP
resource "azurerm_public_ip" "public-ip" {

  allocation_method   = "Static"
  location            = var.location
  name                = "${var.product_name}-public-ip"
  resource_group_name = azurerm_resource_group.moodle-rg.name

  tags = merge(local.common_tags)
}

# Network Security Group
resource "azurerm_network_security_group" "nsg" {
  location            = var.location
  name                = "${var.product_name}-nsg"
  resource_group_name = azurerm_resource_group.moodle-rg.name
}

# Network Security Rules
resource "azurerm_network_security_rule" "inbound_allow_https" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "inbound_allow_https"
  network_security_group_name = azurerm_network_security_group.nsg.name
  priority                    = 100
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.moodle-rg.name
  destination_port_range      = "443"
}

resource "azurerm_network_security_rule" "inbound_allow_http" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "inbound_allow_http"
  network_security_group_name = azurerm_network_security_group.nsg.name
  priority                    = 200
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.moodle-rg.name
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "moodle-vm" {
  count                 = 1
  name                  = "${var.product_name}-vm-${count.index}"
  location              = var.location
  resource_group_name   = azurerm_resource_group.moodle-rg.name
  network_interface_ids = azurerm_network_interface.moodle-vm-nic[count.index]
  size               = "Standard_B1s"

  source_image_reference {
    offer     = "0001-com-ubuntu-minimal-lunar"
    publisher = "canonical"
    sku       = "minimal-23_04-ARM"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    name                 = "os_disk"
  }

  admin_username                  = "moodle_admin"
  disable_password_authentication = true

  tags = merge(local.common_tags)
}