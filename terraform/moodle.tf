# Resource Group
resource "azurerm_resource_group" "moodle-rg" {
  name = "moodle-rg"
  location = var.location
  tags = merge(local.common_tags)
}

# VM Nic
resource "azurerm_network_interface" "moodle-vm-nic" {
  count = 1
  name = "${var.product_name}-nic-${count.index}"
  location = var.location
  resource_group_name = azurerm_resource_group.moodle-rg.name
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
  protocol                    = "TCP"
  resource_group_name         = azurerm_resource_group.moodle-rg.name
  destination_port_range      = "443"
}

resource "azurerm_network_security_rule" "inbound_allow_http" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "inbound_allow_http"
  network_security_group_name = azurerm_network_security_group.nsg.name
  priority                    = 200
  protocol                    = "TCP"
  resource_group_name         = azurerm_resource_group.moodle-rg.name
}

# Virtual Machine
resource "azurerm_virtual_machine" "moodle-vm" {
  count = 1
  name                  = "${var.product_name}-vm-${count.index}"
  location              = var.location
  resource_group_name   = azurerm_resource_group.moodle-rg.name
  network_interface_ids = azurerm_network_interface.moodle-vm-nic.id
  vm_size               = "Standard_B1s"

  storage_image_reference {
    publisher = "alertlogic"
    offer     = "alert-logic-tm"
    sku       = "2021500100-tmpbyol"
    version   = "latest"
  }

  plan = merge(local.marketplace_images)

  storage_os_disk {
    create_option     = "FromImage"
    name              = "${var.product_name}-vm-os-disk"
    caching           = "ReadWrite"
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    admin_username = "moodle-vm-admin"
    computer_name  = azurerm_virtual_machine.moodle-vm.name
    admin_password = ""
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = merge(local.common_tags)
}