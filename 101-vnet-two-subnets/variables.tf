# Authentication
provider "azurerm" {
	features {}
	subscription_id	= var.tf_var_arm_subscription_id
	client_id  			= var.tf_var_arm_client_id
	client_secret 	= var.tf_var_arm_client_secret
	tenant_id 			= var.tf_var_arm_tenant_id
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
	default     = "WestUS"
	description = "Location for all resources"
}

variable "vnetName" {
	type        = string
	default     = "VNet1"
	description = "VNet name."
}

variable "vnetAddressPrefix" {
	type        = string
	default 		= "10.0.0.0/16"
	description = "Address prefix."
}

variable "subnet1Prefix" {
	type        = string
	default     = "10.0.0.0/24"
	description = "Subnet 1 Prefix."
}

variable "subnet1Name" {
	type        = string
	default     = "Subnet1"
	description = "Subnet 1 Name."
}

variable "subnet2Prefix" {
	type    		= string
	default 		= "10.0.1.0/24"
	description = "Subnet 2 Prefix."
}

variable "subnet2Name" {
	type    		= string
	default 		= "Subnet2"
	description = "Subnet 2 Name."
}