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
  default     = "terraform-rg"
  description = "Enter the resource group name"
}

variable "vmName" {
  type        = string
  default     = "vm"
  description = "The name of the VMe"

}

variable "adminUsername" {
  type        = string
  default     = "cloudguy"
  description = "The name of the administrator of the new VM. Exclusion list: 'admin','administrator'"
}

variable "adminPassword" {
  type        = string
  description = "The password for the administrator account of the new VM"
}

variable "rdpPort" {
  type        = string
  default     = "50001"
  description = "Public port number for RDP"

}
variable "location" {
  type        = string
  default     = "westus"
  description = "Enter the location for all resources."
}

variable "networkInterfaceName" {
  type        = string
  default     = "nic"
  description = "default Network interface name"
}



variable "dnsLabelPrefix" {
  type        = string
  description = "Unique public DNS prefix for the deployment. The fqdn will look something like '<dnsname>.westus.cloudapp.azure.com'. Up to 62 chars, digits or dashes, lowercase, should start with a letter: must conform to '^[a-z][a-z0-9-]{1,61}[a-z0-9]$'."
}



