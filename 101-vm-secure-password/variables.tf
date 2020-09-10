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

variable "adminUsername" {
  type        = string
  default     = "cloudguy"
  description = "Username for the Virtual Machine."
}

variable "dnsLabelPrefix" {
  type        = string
  default     = "demodnssep2020"
  description = "Unique DNS Name for the Public IP used to access the Virtual Machine."
}

variable "location" {
  type        = string
  default     = "WestUS"
  description = "Location for all resources"
}

variable "windowsOSVersion" {
  type        = string
  default     = "2019-Datacenter"
  description = "The Windows version for the VM. This will pick a fully patched image of this given Windows version."
  validation {
    condition     = contains(["2016-Datacenter", "2012-Datacenter", "2012-R2-Datacenter", "2019-Datacenter"], var.windowsOSVersion)
    error_message = "The Windows version should be one of the following \"2016-Datacenter\",\"2012-Datacenter\",\"2012-R2-Datacenter\",\"2019-Datacenter\"."
  }
}

variable "vmSize" {
  type        = string
  default     = "Standard_D2_v3"
  description = "Size of the virtual machine."
}
