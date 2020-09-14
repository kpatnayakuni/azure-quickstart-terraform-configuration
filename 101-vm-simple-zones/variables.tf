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
  description = "enter subscription id."
}

variable "tf_var_arm_client_id" {
  description = "Enter Client ID."
}

variable "tf_var_arm_client_secret" {
  description = "Enter secret"
}

variable "tf_var_arm_tenant_id" {
  description = "Enter tenant ID."
}

variable "resourceGroupName" {
  type        = string
  default     = "demo-rg"
  description = "Resource Group for this deployment."
}

variable "location" {
  type        = string
  default     = "CentralUs"
  description = "Location for all resources."
}

variable "vmName" {
  type        = string
  default     = "linuxvm"
  description = "The name of you Virtual Machine."
}

variable "adminUsername" {
  type        = string
  default     = "demouser"
  description = "Username for the Virtual Machine."
}

variable "authenticationType" {
  type        = string
  default     = "password"
  description = "Type of authentication to be used on the Virtual Machine. SSH key is recommended but if you want to use password authentication use 'password'"
  validation {
    condition     = var.authenticationType == "sshPublicKey" || var.authenticationType == "password"
    error_message = "Authentication type hould be either \"ssh\" or \"password\"."
  }
}

variable "adminPasswordOrKey" {
  type        = string
  default     = "Abcd@123"
  description = "SSH Key or password for the Virtual Machine. SSH key is recommended."
}


variable "ubuntuOSVersion" {
  type        = string
  default     = "18.04-LTS"
  description = "The Ubuntu version for the VM. This will pick a fully patched image of this given Ubuntu version."
  validation {
    condition     = contains(["12.04.5-LTS", "14.04.5-LTS", "16.04.0-LTS", "18.04-LTS"], var.ubuntuOSVersion)
    error_message = "The linux version of VM are 12.04.5-LTS, 14.04.5-LTS, 16.04.0-LTS, 18.04-LTS."
  }
}

variable "VmSize" {
  type        = string
  default     = "Standard_B2s"
  description = "The size of the VM"
}

variable "virtualNetworkName" {
  type        = string
  default     = "vNet"
  description = "ame of the VNET"
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

variable "zone" {
  type        = string
  default     = 1
  description = "Zone number for the virtual machine"
  validation {
    condition     = contains(["1", "2", "3"], var.zone)
    error_message = "Zone number for the virtual machine should be 1 or 2 or 3."
  }
}