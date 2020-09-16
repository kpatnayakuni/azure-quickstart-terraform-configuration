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
  default     = "westus"
  description = "Location for all resources."
}

variable "vmSku" {
  type        = string
  default     = "Standard_D1_v2"
  description = "Size of VMs in the VM Scale Set."
}

variable "vmssName" {
  type        = string
  description = "String used as a base for naming resources (9 characters or less). A hash is prepended to this string for some resources, and resource-specific information is appended."
  validation {
    condition     = length(var.vmssName) <= 9
    error_message = "String used as a base for naming resources (9 characters or less)."
  }
}

variable "instanceCount" {
  default     = 3
  description = "Number of VM instances (100 or less)"
  validation {
    condition     = var.instanceCount >= 1 || var.instanceCount <= 100
    error_message = "Number of VM instances (100 or less)."
  }
}

variable "adminUsername" {
  type        = string
  description = "Admin username on all VMs"
}

variable "publicIPPrefixLength" {
  default     = 30
  description = "Length of public IP prefix."
  validation {
    condition     = var.publicIPPrefixLength == 30 || var.publicIPPrefixLength == 31
    error_message = "Max Length of public IP prefix is 31 and min Length is 30."
  }
}

variable "authenticationType" {
  type        = string
  default     = "sshPublicKey"
  description = "Type of authentication to use on the Virtual Machine. SSH key is recommended"
  validation {
    condition     = var.authenticationType == "sshPublicKey" || var.authenticationType == "password"
    error_message = "Authentication type hould be either \"ssh\" or \"password\"."
  }
}

variable "adminPasswordOrKey" {
  type        = string
  description = "SSH Key or password for the Virtual Machine. SSH key is recommended."
}
