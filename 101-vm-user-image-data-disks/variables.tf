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
  description = "Password for the Virtual Machine. SSH key is recommended"
}

variable "vnet-new-or-existing" {
  type        = string
  description = "Select if this template needs a new VNet or will reference an existing VNet."
  validation {
    condition     = var.vnet-new-or-existing == "new" || var.vnet-new-or-existing == "existing"
    error_message = "Accepts values either \"new\",\"existing\"."
  }
}