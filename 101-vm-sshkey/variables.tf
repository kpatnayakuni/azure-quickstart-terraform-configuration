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

variable "projectName" {
  type        = string
  description = "Specifies a name for generating resource names."
}

variable "adminUsername" {
  type        = string
  description = "Specifies a username for the Virtual Machine."
}

variable "adminPublicKey" {
  type        = string
  description = "Specifies the SSH rsa public key file as a string. Use \"ssh-keygen -t rsa -b 2048\" to generate your SSH key pairs"
}
