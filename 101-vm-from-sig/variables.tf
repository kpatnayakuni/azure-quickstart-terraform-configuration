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
  default     = "tf-rg"
  description = "Resource Group for this deployment."
}

variable "dnsLabelPrefix" {
  type        = string
  default     = "demodnssep"
  description = "Unique DNS Name for the Public IP used to acces virtual machine"
}

variable "adminUsername" {
  type        = string
  description = "Default Admin username"
  default     = "cloudguy"
}

variable "adminPassword" {
  type        = string
  description = "Password for the Virtual Machine. SSH key is recommended"
  default     = "Abcd@1234"
}

variable "location" {
  type        = string
  default     = "westus"
  description = "Enter the location for all resources."
}

variable "galleryName" {
  type        = string
  description = "Name of the Shared Image Gallery."
}

variable "galleryImageDefinitionName" {
  type        = string
  description = "Name of the Image Definition."
}

variable "galleryImageVersionName" {
  type        = string
  description = "Name of the Image Version - should follow <MajorVersion>.<MinorVersion>.<Patch>."
}

variable "os_type" {
  type        = string
  default     = "linux"
  description = "OS type of the gallery image. either Linux or Windows"
}
