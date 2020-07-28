# Authentication
provider "azurerm" {
    features {}
     subscription_id = var.tf_var_arm_subscription_id
     client_id  = var.tf_var_arm_client_id
     client_secret = var.tf_var_arm_client_secret
     tenant_id = var.tf_var_arm_tenant_id
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
    type = string
    default = "terraform-rg"
    description = "Enter the resource group name"
}

variable "adminUsername" {
    type = string
    default = "demo_user"
    description= "Default Admin username"
}

variable "adminPassword" {
    type = string
    description = "Default Admin password"
}

variable "vmnameprefix" {
    type = string
    default = "backendvm"
    description = "Prefix to use for VM Names"
}

variable "networkInterfaceName" {
    type = string
    default = "nic"
    description = "default Network interface name"
}

variable "location" {
    type = string
    default = "westus"
    description = "Enter the location for all resources."
}