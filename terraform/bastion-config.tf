
# Create subnets
resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resourceGroupName
  virtual_network_name = azurerm_virtual_network.VNet.name
  address_prefixes     = ["10.0.2.0/24"]
  depends_on = [
    azurerm_resource_group.rg-virtualMachines,
    azurerm_virtual_network.VNet
  ]
}

resource "azurerm_public_ip" "bastion_publicIP" {
  name                = "bastion-publicIP"
  location            = var.region
  resource_group_name = var.resourceGroupName
  allocation_method   = "Static"
  sku                 = "Standard"   # Standard or Basic
  depends_on = [
    azurerm_resource_group.rg-virtualMachines,
    azurerm_virtual_network.VNet,
    azurerm_subnet.bastion_subnet
  ]
 tags = "${var.tags}"
}

resource "azurerm_bastion_host" "bastion_host" {
  name                = "bastion-host"
  location            = var.region
  resource_group_name = var.resourceGroupName
  sku                 = "Standard"  # Standard or Basic
  scale_units         = 2

  copy_paste_enabled     = true
  file_copy_enabled      = true  # Not Available on Basic
  shareable_link_enabled = true  # Not Available on Basic
  tunneling_enabled      = true  # Not Available on Basic
  ip_connect_enabled     = true  # Not Available on Basic

  ip_configuration {
    name                 = "config-01"
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_publicIP.id
  }

  depends_on = [
    azurerm_resource_group.rg-virtualMachines,
    azurerm_virtual_network.VNet
  ]
  tags = "${var.tags}"
}