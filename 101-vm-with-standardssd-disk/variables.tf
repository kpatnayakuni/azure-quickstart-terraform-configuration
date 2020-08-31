# Authentication
provider "azurerm" {
  features {}
  subscription_id = var.tf_var_arm_subscription_id
  client_id       = var.tf_var_arm_client_id
  client_secret   = var.tf_var_arm_client_secret
  tenant_id       = var.tf_var_arm_tenant_id
}

# Variable declaration
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
  default     = "demo-rg"
  description = "Resource Group for this deployment."
}

variable "location" {
  type        = string
  default     = "WestUS"
  description = "Location for all resources"
}

variable "virtualMachineName" {
  type        = string
  default     = "demomachine"
  description = "The name of the VM"
}

variable "adminUsername" {
  type        = string
  description = "The admin user name of the VM."
}

variable "adminPassword" {
  type        = string
  description = "The admin password of the VM."
}

variable "disktype" {
  type        = list
  default     = ["StandardSSD_LRS", "Standard_LRS", "Premium_LRS"]
  description = "The Storage type of the data Disks."
}

variable "virtualMachineSize" {
  type        = string
  default     = "Standard_DS3_V2"
  description = "The virtual machine size. Enter a Premium capable VM size if DiskType is entered as Premium_LRS."
}

variable "windowsOSVersion" {
  type        = list
  default     = ["2008-R2-SP1", "2012-Datacenter", "2012-R2-Datacente", "2016-Datacenter"]
  description = "The Windows version for the VM."
}
