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
  default     = "tf-rg"
  description = "Resource Group for this deployment."
}

variable "location" {
  type        = string
  default     = "WestUS"
  description = "Location for all resources"
}

variable "adminUsername" {
  type        = string
  description = "The admin user name of the VM."
}

variable "adminPassword" {
  type        = string
  description = "The admin password of the VM."
}

variable "vmSize" {
  type        = string
  description = "Size of VM"
}

variable "dnsLabelPrefix" {
  type        = string
  description = "Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed."
}

variable "sizeOfEachDataDiskInGB" {
  type        = string
  description = "Size of each data disk in GB"
}
