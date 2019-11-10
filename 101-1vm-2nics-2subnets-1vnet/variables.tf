provider "azurerm" {
    subscription_id = "${var.subscription_id}"
    client_id       = "${var.client_id}"
    client_secret   = "${var.client_secret}"
    tenant_id       = "${var.tenant_id}"
}

variable "subscription_id" {
    description = "Enter Subscription ID for provisioning resources in Azure"
}

variable "client_id" {
    description = "Enter Client ID for Application created in Azure AD"
}

variable "client_secret" {
    description = "Enter Client secret for Application created in Azure AD"
}

variable "tenant_id" {
    description = "Enter Tenant ID /Directory ID of your Azure AD. Run Get-AzSubscription in your PowerShell Window to get the Tenant ID."
}

variable "resource_group_name" {
    type = "string"
    default = "terraform-rg"
    description = "Enter the resource group name"
}

variable "virtual_machine_size" {
    type = "string"
    default = "Standard_DS1_v2"
    description = "Virtual machine size (has to be at least the size of Standard_A3 to support 2 NICs)"
}

variable "admin_username" {
    type = "string"
    description= "Default Admin username"
}

variable "admin_password" {
    type = "string"
    description = "Default Admin password"
}

variable "storage_account_type" {
    type = "string"
    default = "Standard"
    description = "Storage Account type for the VM and VM diagnostic storage"
}
variable "location" {
    type = "string"
    default = "westus"
    description = "Enter the location for all resources."
}




