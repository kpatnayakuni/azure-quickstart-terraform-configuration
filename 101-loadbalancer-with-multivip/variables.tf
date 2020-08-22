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
	description = "Azure region for Bastion and virtual network"
}

variable "location" {
	type        = string
	default     = "westus"
	description = "Enter the location for the resource group"
}

variable "dnsNameforLBIP" {
    type        = string
    default     = "dnsdemo"
    description = "Unique DNS name"
}

variable "addressPrefix" {
	type  			= string
	default 		= "10.0.0.0/16"
	description = "Address Prefix"
}

variable "subnetprefix" {
	type				= string
	default			= "10.0.0.0/24"
	description = "Subnet Prefix"
}

variable "publicIPAddressType" {
	type				= list 
	default			= ["Dynamic","Static"]
	description = "Public IP type"
}
