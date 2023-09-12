resource "azurerm_ssh_public_key" "sshpubkey" {
  name                = "Moodle-PubKey"
  resource_group_name = var.resourceGroupName
  location            = var.region
  public_key          = var.ssh_pub_key  # Password Required
  
  tags = "${var.tags}"
  depends_on=[
    azurerm_resource_group.rg-virtualMachines,
    azurerm_virtual_network.VNet
    ]
}