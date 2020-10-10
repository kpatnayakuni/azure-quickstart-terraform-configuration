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
  description = "Resource Group for this deployment."
}

variable "location" {
  type        = string
  default     = "westus"
  description = "Location for all resources"
}

variable "newStorageAccountName" {
  type        = string
  description = "Name of new storage account"
}

variable "replicationtype" {
  type        = string
  default     = "LRS"
  description = "Replication Type of storage account"
  validation {
    condition     = contains(["LRS", "GRS"], var.replicationtype)
    error_message = "Type of replication contains only LRS and GRS."
  }
}

variable "tier" {
  type        = string
  default     = "Standard"
  description = "Type of storage account"
}

variable "publicIPName" {
  type        = string
  description = "Name of Public IP."
}

variable "publicIPAddressType" {
  type        = string
  default     = "Dynamic"
  description = "Type of Public Address."
  validation {
    condition     = contains(["Dynamic"], var.publicIPAddressType)
    error_message = "The only public address type is Dynamic."
  }
}

variable "vmName" {
  type        = string
  description = "Name of the VM."
}

variable "vmSize" {
  type        = string
  default     = "Standard_A1_v2"
  description = "Size of the VM."
}

variable "imagePublisher" {
  type        = string
  default     = "Canonical"
  description = "Image Publisher."
}

variable "imageOffer" {
  type        = string
  default     = "UbuntuServer"
  description = "Image Offer."
}

variable "imageSKU" {
  type        = string
  default     = "18.04-LTS"
  description = "Image SKU"
  validation {
    condition     = contains(["14.04.5-LTS", "16.04-LTS", "18.04-LTS"], var.imageSKU)
    error_message = "Allowed values: 14.04.5-LTS, 16.04-LTS, 18.04-LTS."
  }
}

variable "adminUsername" {
  type        = string
  description = "VM Admin Username."
}

variable "virtualNetworkName" {
  type        = string
  description = "VNET Name."
}

variable "virtualNetworkResourceGroup" {
  type        = string
  description = "Resource Group VNET is deployed in"
}

variable "subnet1Name" {
  type        = string
  description = "Name of the subnet inside the VNET."
}

variable "nicName" {
  type        = string
  description = "Network Interface Name."
}

variable "adminPassword" {
  type        = string
  description = "SSH Key or password for the Virtual Machine. SSH key is recommended."
}

variable "authenticationType" {
  type        = string
  default     = "sshPublicKey"
  description = "Type of authentication to use on the Virtual Machine. SSH key is recommended but if you want to use password authentication use 'password'"
  validation {
    condition     = var.authenticationType == "sshPublicKey" || var.authenticationType == "password"
    error_message = "Authentication type hould be either \"ssh\" or \"password\"."
  }
}
