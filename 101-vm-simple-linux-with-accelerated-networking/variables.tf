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

variable "dnsLabelPrefix" {
  type        = string
  default     = "demodnssep"
  description = "Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed."
}

variable "adminUsername" {
  type        = string
  description = "Default Admin username"
}

variable "adminPassword" {
  type        = string
  description = "Password for the Virtual Machine. SSH key is recommended"

}

variable "authenticationType" {
  type        = string
  default     = "sshPublicKey"
  description = "Type of authentication to be used on the Virtual Machine. SSH key is recommended but if you want to use password authentication use 'password'"
  validation {
    condition     = var.authenticationType == "sshPublicKey" || var.authenticationType == "password"
    error_message = "Authentication type hould be either \"ssh\" or \"password\"."
  }
}

variable "location" {
  type        = string
  default     = "westus"
  description = "Enter the location for all resources."
}
