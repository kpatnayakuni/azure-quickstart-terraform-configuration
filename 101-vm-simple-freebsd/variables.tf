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
}

variable "adminPasswordOrKey" {
  type        = string
  description = "SSH Key or password for the Virtual Machine. SSH key is recommended."
}

variable "dnsLabelPrefix" {
  type        = string
  description = "Unique DNS Name for the Public IP used to access the Virtual Machine."
}

variable "freeBSDOSVersion" {
  type        = list
  default     = ["11.2", "11.1", "11.0", "10.3"]
  description = "The FreeBSD version for the VM. This will pick a fully patched image of this given FreeBSD version."
}

variable "authenticationType" {
  type        = string
  default     = "ssh"
  description = "Type of authentication to be used on the Virtual Machine. SSH key is recommended but if you want to use password authentication use 'password'"
  validation {
    condition     = var.authenticationType == "ssh" || var.authenticationType == "password"
    error_message = "Authentication type hould be either \"ssh\" or \"password\"."
  }
}
