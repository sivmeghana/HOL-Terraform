provider "azurerm" {
}


resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group}"
  location = "${var.location}"

  tags {
    environment = "Terraform HOL bootcamp"
  }
}

  module "network" {
    source              = "Azure/network/azurerm"
    version             = "~> 1.1.1"
    location            = "West US 2"
    allow_rdp_traffic   = "true"
    allow_ssh_traffic   = "true"
    resource_group_name = "${var.resource_group}"
  }

  module "linuxservers" {
    source              = "Azure/compute/azurerm"
    location            = "${var.location}"
    vm_os_simple        = "UbuntuServer"
    public_ip_dns       = ["linsimplevmips"] // change to a unique name per datacenter region
    vnet_subnet_id      = "${module.network.vnet_subnets[0]}"
  }
