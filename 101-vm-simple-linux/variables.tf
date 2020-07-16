provider "azurerm" {
  features {}
  version         = "~>2.0"
  subscription_id = var.tf_var_arm_subscription_id
  client_id       = var.tf_var_arm_client_id
  client_secret   = var.tf_var_arm_client_secret
  tenant_id       = var.tf_var_arm_tenant_id
}

variable "tf_var_arm_subscription_id" {
  description = "enter subscription id"
}

variable "tf_var_arm_client_id" {
  description = "Enter Client ID"
}

variable "tf_var_arm_client_secret" {
  description = "Enter secret"
}

variable "tf_var_arm_tenant_id" {
  description = "Enter tenant ID"
}

variable "resourceGroupName" {
  type        = string
  description = "Resource Group for this deployment."
}

variable "vmName" {
  type        = string
  default     = "simpleLinuxVM"
  description = "The name of you Virtual Machine"
}

variable "admin_username" {
  type        = string
  description = "Default Admin username"
}

variable "adminPassword" {
  type        = string
  description = "Password for the Virtual Machine. SSH key is recommended"

}

variable "authenticationType" {
  type        = string
  default     = "ssh"
  description = "Type of authentication to use on the Virtual Machine. SSH key is recommended."
}

variable "UbuntuOSVersion" {
  type        = list
  default     = ["18.04-LTS", "12.04.5-LTS", "14.04.5-LTS", "16.04.0-LTS", "18.04-LTS"]
  description = "The Ubuntu version for the VM. This will pick a fully patched image of this given Ubuntu version"
}

variable "VmSize" {
  type        = string
  default     = "Standard_B2s"
  description = "The size of the VM"
}

variable "virtualNetworkName" {
  type        = string
  default     = "vNet"
  description = "Name of the VNET"
}

variable "subnetName" {
  type        = string
  default     = "Subnet"
  description = "Name of the subnet in the virtual network"
}

variable "networkSecurityGroupName" {
  type        = string
  default     = "SecGroupNet"
  description = "Name of the Network Security Group"
}

variable "location" {
  type        = string
  default     = "westus"
  description = "Enter the location for all resources."
}
