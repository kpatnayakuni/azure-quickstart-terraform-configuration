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


/* variable "resourceGroupName" {
  type        = string
  default     = "tf-rg"
  description = "Resource Group for this deployment."
}

variable "vmName" {
  type        = string
  default     = "vmName"
  description = "The name of you Virtual Machine"
}

variable "location" {
  type        = string
  default     = "westus"
  description = "Enter the location for all resources."
}

variable "cpu-gpu" {
  type        = string
  default     = "CPU-4GB"
  description = "Choose between CPU or GPU processing"
  validation {
    condition     = contains(["CPU-4GB", "CPU-7GB", "CPU-8GB", "CPU-14GB", "CPU-16GB", "GPU-56GB"], var.cpu-gpu)
    error_message = "The cpu-gpu value must be one of \"CPU-4GB\",\"CPU-7GB\",\"CPU-8GB\",\"CPU-14GB\",\"CPU-16GB\",\"GPU-56GB\"."
  }
}

variable "admin_username" {
  type        = string
  description = "Default Admin username"
}

variable "adminPassword" {
  type        = string
  description = "Password for the Virtual Machine. SSH key is recommended"
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

variable "authenticationType" {
  type        = string
  default     = "password"
  description = "Type of authentication to be used on the Virtual Machine. SSH key is recommended but if you want to use password authentication use 'password'"
  validation {
    condition     = var.authenticationType == "ssh" || var.authenticationType == "password"
    error_message = "Authentication type hould be either \"ssh\" or \"password\"."
  }
}
*/