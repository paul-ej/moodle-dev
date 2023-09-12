
/* -------------------------------------------------------------------------- */
/*                              Create Ubuntu VM                              */
/* -------------------------------------------------------------------------- */

# Create Network Card for Ubuntu Server
resource "azurerm_network_interface" "vm-ubuntu-nic" {
  count               = var.ubuntu_vm_count
  name                = "${var.ubuntu_vm_name_prefix}-${count.index}-nic"
  location            = var.region
  resource_group_name = var.resourceGroupName
  
  ip_configuration {
    name                          = "Main"
    subnet_id                     = azurerm_subnet.MainSubnet.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = "${var.tags}"
  depends_on = [
    azurerm_resource_group.rg-virtualMachines,
    azurerm_virtual_network.VNet,
    azurerm_subnet.MainSubnet
    ]
}

# file for bootstrapping 
data "template_file" "linux-vm-cloud-init" {
  template = file("ubuntu-data.sh")
}

resource "azurerm_linux_virtual_machine" "ubuntu-vm" {
  count                 = var.ubuntu_vm_count # Count Value read from variable
  name                  = "${var.ubuntu_vm_name_prefix}-${count.index}" # Name constructed using count and prefix
  location              = var.region
  resource_group_name   = var.resourceGroupName
  network_interface_ids = [azurerm_network_interface.vm-ubuntu-nic[count.index].id]
  size                  = var.ubuntu_vm_size

  source_image_reference {
    publisher = var.ubuntu_vm_OS_publisher
    offer     = var.ubuntu_vm_OS_offer
    sku       = var.ubuntu_vm_OS_SKU
    # version = "latest"
  }

  os_disk {
    name                 = "${var.ubuntu_vm_name_prefix}-${count.index}-OSDisk"
    caching              = "ReadWrite"
    storage_account_type = var.ubuntu_vm_storage_account_type
    disk_size_gb         = var.ubuntu_vm_disk_size
  }

  computer_name                   = "${var.ubuntu_vm_name_prefix}-${count.index}"
  admin_username                  = var.ubuntu_vm_admin_user
  disable_password_authentication = true

  admin_ssh_key {
        username = var.ubuntu_vm_admin_user
        public_key = azurerm_ssh_public_key.sshpubkey.public_key
  }
  tags = "${var.tags}"
  custom_data    = base64encode(data.template_file.linux-vm-cloud-init.rendered)
  depends_on = [
    azurerm_resource_group.rg-virtualMachines,
    azurerm_network_interface.vm-ubuntu-nic,
    azurerm_virtual_network.VNet,
    azurerm_subnet.MainSubnet
  ]
}