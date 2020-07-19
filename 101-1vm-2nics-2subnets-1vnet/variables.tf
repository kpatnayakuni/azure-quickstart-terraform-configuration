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

variable "virtual_machine_size" {
    type = string
    default = "Standard_DS1_v2"
    description = "Virtual machine size (has to be at least the size of Standard_A3 to support 2 NICs)"
}

variable "admin_username" {
    type = string
    default = "demo_user"
    description= "Default Admin username"
}

variable "admin_password" {
    type = string
    description = "Default Admin password"
}

variable "storage_account_type" {
    type = string
    default = "Standard"
    description = "Storage Account type for the VM and VM diagnostic storage"
}
variable "location" {
    type = string
    default = "westus"
    description = "Enter the location for all resources."
}
