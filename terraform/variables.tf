/* -------------------------------------------------------------------------- */
/*                                    Tags                                    */
/* -------------------------------------------------------------------------- */
variable "tags" {
    description = "A map of the tags to use for the resources that are deployed."
    type        = map(string)

    default = {
        name                    = "Moodle-BEJ-Masters"
        application             = "Moodle"
        environment             = "Sandbox"
        owner                   = "paul@paul-ej.dev"
        securitycontact         = "paul@paul-ej.dev"
    }
}

/* -------------------------------------------------------------------------- */
/*                                VMs to Build                                */
/* -------------------------------------------------------------------------- */

variable "ubuntu_vm_count" {
  description = "Number of Ubuntu Virtual Servers"
  default     = 1
  type        = string
}

/* -------------------------------------------------------------------------- */
/*                    VM Names/User/Pass                                      */
/* -------------------------------------------------------------------------- */

variable "ubuntu_vm_name_prefix" {
  description = "Ubuntu VM Name prefix"
  default     = "vm-ubuntu"
  type        = string
}

variable "ubuntu_vm_admin_user" {
  type        = string
  description = "Admin User "
  default     = "security-engineering"
}


/* -------------------------------------------------------------------------- */
/*                             Network Variables                              */
/* -------------------------------------------------------------------------- */

variable "resourceGroupName" {
    type = string
    description = "Resource Group Name to install into"
    default = "rg-wppit-cybersec-uks-x-1234"
}

variable "region" {
    type        = string
    description = "The Region where you want to install into"
    default = "UK South"
}

/* -------------------------------------------------------------------------- */
/*                             Ubuntu VM Variables                            */
/* -------------------------------------------------------------------------- */

variable "ubuntu_vm_size" {
  type        = string
  description = "Virtual machine size"
  default     = "Standard_B2s"
}

variable "ubuntu_vm_disk_size" {
  type        = string
  description = "Disk size in GB"
  default     = "30"   # 30gb in Dev/Sandbox
}

variable "ubuntu_vm_disk_name" {
  type        = string
  description = "Disk Naming"
  default     = "ubuntu-OSDisk-vm"
}

variable "ubuntu_vm_storage_account_type" {
  type        = string
  description = "Disk Type"
  default     = "Standard_LRS"
}

variable "ubuntu_vm_OS_publisher" {
  type        = string
  description = "OS Publisher"
  default     = "bitnami"
}

variable "ubuntu_vm_OS_offer" {
  type        = string
  description = "OS Offer"
  default     = "moodle"
}

variable "ubuntu_vm_OS_SKU" {
  type        = string
  description = "OS Offer"
  default     = "3-0"
}

/* -------------------------------------------------------------------------- */
/*                                     SSH                                    */
/* -------------------------------------------------------------------------- */

variable "ssh_pub_key" {
  type        = string
  description = "PublicKey for Moodle VM"
}