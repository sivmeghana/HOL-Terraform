provider "azurerm" {
  subscription_id = "1da42ac9-ee3e-4fdb-b294-f7a607f589d5"
  client_id       = "b37561f6-5f97-4159-ac96-dc0d87719737"
  client_secret   = "<YOUR SECRET>"
  tenant_id       = "2e3a33f9-66b1-4e2a-8b95-74102ad857c2"
}

variable "resource_group" {
  description = "The name of the resource group in which to create the virtual network."
  default     = "rg_hol_terraform"
}

variable "project_name" {
  description = "The shortened abbreviation to represent your project name."
  default     = "holterraform"
}

variable "location" {
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created."
  default     = "West Europe"
}

variable "admin_username" {
  description = "administrator user name"
  default     = "vmadmin"
}

variable "admin_password" {
  description = "vmpassword"
  default     = "vmadmin123*"
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group}"
  location = "${var.location}"

  tags {
    environment = "Terraform HOL bootcamp"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.project_name}vnet"
  location            = "${var.location}"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = "${azurerm_resource_group.rg.name}"

  tags {
    environment = "Terraform HOL bootcamp"
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.project_name}subnet"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  address_prefix       = "10.0.10.0/24"
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.project_name}nic"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "${var.project_name}ipconfig"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.pip.id}"
  }
}

resource "azurerm_public_ip" "pip" {
  name                         = "${var.project_name}-ip"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "Dynamic"
  domain_name_label            = "holterraform"

  tags {
    environment = "Terraform HOL bootcamp"
  }
}

resource "azurerm_storage_account" "stor" {
  name                     = "${var.project_name}stor"
  location                 = "${var.location}"
  resource_group_name      = "${azurerm_resource_group.rg.name}"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags {
    environment = "Terraform HOL bootcamp"
  }
}

resource "azurerm_managed_disk" "datadisk" {
  name                 = "${var.project_name}-datadisk"
  location             = "${var.location}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1023"

  tags {
    environment = "Terraform HOL bootcamp"
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "${var.project_name}vm"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  vm_size               = "Standard_DS1_v2"
  network_interface_ids = ["${azurerm_network_interface.nic.id}"]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.project_name}-osdisk"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  storage_data_disk {
    name              = "${var.project_name}-datadisk"
    managed_disk_id   = "${azurerm_managed_disk.datadisk.id}"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = "1023"
    create_option     = "Attach"
    lun               = 0
  }

  os_profile {
    computer_name  = "VMHOL"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = "${azurerm_storage_account.stor.primary_blob_endpoint}"
  }
}
