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

variable "admin_username" {
  type        = string
  description = "Default Admin username"
}

variable "adminPassword" {
  type        = string
  description = "Password for the Virtual Machine.
}

variable "sharedResources" {
  type        = string
  default     = "new"
  description = "Specify whether to create a new or existing NSG and vNet."
  validation {
    condition     = var.sharedResources == "new" || var.sharedResources == "existing"
    error_message = "Accepts values either \"new\",\"existing\"."
  }
}
