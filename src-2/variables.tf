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

variable "subnet_id" {}
