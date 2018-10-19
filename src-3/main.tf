provider "azurerm" {
  subscription_id = "1da42ac9-ee3e-4fdb-b294-f7a607f589d5"
  client_id       = "b37561f6-5f97-4159-ac96-dc0d87719737"
  client_secret   = "OxCV/9IqosAH/anlSJpkkQyZ3cP+370u63pzZ/1wl6g="
  tenant_id       = "2e3a33f9-66b1-4e2a-8b95-74102ad857c2"
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