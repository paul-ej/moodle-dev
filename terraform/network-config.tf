

resource "azurerm_resource_group" "rg-virtualMachines" {
  name     = var.resourceGroupName
  location = var.region
  tags = "${var.tags}"
}

# Create the Virtual Network 
resource "azurerm_virtual_network" "VNet" {
  name                = "virtual-network"
  location            = var.region
  resource_group_name = var.resourceGroupName
  address_space       = ["10.0.0.0/16"]
  depends_on = [
    azurerm_resource_group.rg-virtualMachines
  ]
  tags = "${var.tags}"
}

# Create a subnet for the main subnet
resource "azurerm_subnet" "MainSubnet" {
  name = "MainSubnet"
  address_prefixes = ["10.0.1.0/24"]
  virtual_network_name = azurerm_virtual_network.VNet.name
  resource_group_name = var.resourceGroupName
  depends_on = [
    azurerm_resource_group.rg-virtualMachines,
    azurerm_virtual_network.VNet
  ]
}

# Create Network Security Group for VM Subnet and the corresponding rule for RDP from Azure Bastion
resource "azurerm_network_security_group" "main_subnet_nsg" {
  name                = "nsg-MainSubnet"
  location            = var.region
  resource_group_name = var.resourceGroupName
  depends_on = [
    azurerm_resource_group.rg-virtualMachines,
    azurerm_virtual_network.VNet,
    azurerm_subnet.bastion_subnet
  ]
  tags = "${var.tags}"
}

resource "azurerm_network_security_rule" "inbound_allow_ssh_bastion" {
  network_security_group_name = azurerm_network_security_group.main_subnet_nsg.name
  resource_group_name         = var.resourceGroupName
  name                        = "Inbound_Allow_Bastion_SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = azurerm_subnet.bastion_subnet.address_prefixes[0]
  destination_address_prefix  = azurerm_subnet.MainSubnet.address_prefixes[0]
  depends_on = [
    azurerm_network_security_group.main_subnet_nsg
  ]
}

resource "azurerm_network_security_rule" "inbound_allow_RDP_bastion" {
  network_security_group_name = azurerm_network_security_group.main_subnet_nsg.name
  resource_group_name         = var.resourceGroupName
  name                        = "Inbound_Allow_Bastion_RDP"
  priority                    = 500
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = azurerm_subnet.bastion_subnet.address_prefixes[0]
  destination_address_prefix  = azurerm_subnet.MainSubnet.address_prefixes[0]
  depends_on = [
    azurerm_network_security_group.main_subnet_nsg
  ]
}

resource "azurerm_network_security_rule" "inbound_allow_https_moodle" {
  network_security_group_name = azurerm_network_security_group.main_subnet_nsg.name
  resource_group_name         = var.resourceGroupName
  name                        = "Inbound_Allow_Bastion_RDP"
  priority                    = 600
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = azurerm_subnet.bastion_subnet.address_prefixes[0]
  destination_address_prefix  = azurerm_subnet.MainSubnet.address_prefixes[0]
  depends_on = [
    azurerm_network_security_group.main_subnet_nsg
  ]
}

resource "azurerm_network_security_rule" "outbound_allow_all" {
  network_security_group_name = azurerm_network_security_group.main_subnet_nsg.name
  resource_group_name         = var.resourceGroupName
  name                        = "Outbound_Allow_Any_Any"
  priority                    = 1000
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = azurerm_subnet.MainSubnet.address_prefixes[0]
  destination_address_prefix  = "*"
  depends_on = [
    azurerm_network_security_group.main_subnet_nsg
  ]
}

resource "azurerm_subnet_network_security_group_association" "nsg_vm_subnet_association" {
  network_security_group_id = azurerm_network_security_group.main_subnet_nsg.id
  subnet_id                 = azurerm_subnet.MainSubnet.id
  depends_on = [
    azurerm_network_security_group.main_subnet_nsg
  ]
}