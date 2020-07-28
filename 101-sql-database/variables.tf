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

variable "resource_group_name" {
  type        = string
  default     = "terraform-rg"
  description = "Enter the resource group name"
}

variable "SQLServer" {
  type        = string
  description = "The name of the SQL logical server."
}

variable "sqldbname" {
  type    = string
  default = "simpledb"
}

variable "location" {
  type    = string
  default = "westus"
}

variable "administratorLogin" {
  type        = string
  default     = "demouser"
  description = "The administrator username of the SQL logical server."
}

variable "administratorLoginPassword" {
  type        = string
  description = "The administrator password of the SQL logical server."
}