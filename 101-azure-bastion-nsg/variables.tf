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

variable "resourcegroupname" {
  type        = string
  default     = "demo-rg"
  description = "Azure region for Bastion and virtual network"

}

variable "rg-location" {
  type        = string
  default     = "westus"
  description = "Enter the location for the resorce group"

}

variable "vnet-name" {
  type        = string
  default     = "vnet01"
  description = "Name of new or existing vnet to which Azure Bastion should be deployed"
}

variable "vnet-ip-prefix" {
  type    = string
  default = "10.1.0.0/16"
  description = "IP prefix for available addresses in vnet address space"
}

variable "vnet-new-or-existing" {
  type  = string
  description = "Specify whether to provision new vnet or deploy to existing vnet"
}

 variable "vnetname-existing" {
  type = string
  default = "vnet-existing"
  description = "enter existing vnet name"
}

variable "existing-rg" {
  type = string
  default = "vnet-rg"
  description = "Enter exisitng RG name"
}  

variable "bastion-host-name" {
  type         = string
  default      = "bastion-host"
   description = "Name of Azure Bastion resource"

}

variable "bastion-subnet-ip-prefix" {
  type        = string
  default     = "10.1.1.0/27"
  description = "Bastion subnet IP prefix MUST be within vnet IP prefix address space"
}