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
  default     = "westus"
  description = "Enter the location for all resources."
}

variable "adminUsername" {
  type        = string
  description = "User name for the Virtual Machine"
  default     = "cloudguy"
}

variable "vmName" {
  type        = string
  description = "Name for the Virtual Machine"
}

variable "adminPassword" {
  type        = string
  description = "password for the Virtual Machine. SSH key is recommended."
  default     = "Abcd@1234"
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
