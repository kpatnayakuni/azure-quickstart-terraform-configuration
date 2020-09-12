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
  description = "Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed."
}

variable "adminUsername" {
  type        = string
  description = "Default Admin username"
}

variable "customData" {
  default     = "echo customData"
  description = "String passed down to the Virtual Machine."
}

variable "vmSize" {
  type        = string
  default     = "Standard_D1"
  description = "VmSize"
}

variable "adminPassword" {
  type        = string
  description = "Password for the Virtual Machine. SSH key is recommended"

}

variable "authenticationType" {
  type        = string
  default     = "sshPublicKey"
  description = "Type of authentication to be used on the Virtual Machine. SSH key is recommended but if you want to use password authentication use 'password'"
  validation {
    condition     = var.authenticationType == "sshPublicKey" || var.authenticationType == "password"
    error_message = "Authentication type hould be either \"ssh\" or \"password\"."
  }
}

variable "UbuntuOSVersion" {
  type        = string
  default     = "18.04-LTS"
  description = "The Ubuntu version for the VM. This will pick a fully patched image of this given Ubuntu version"
  validation {
    condition     = contains(["18.04-LTS", "12.04.5-LTS", "14.04.5-LTS", "16.04.0-LTS", "18.04-LTS"], var.UbuntuOSVersion)
    error_message = "The Ubuntu version should be one of the following \"18.04-LTS\",\"12.04.5-LTS\",\"14.04.5-LTS\",\"16.04.0-LTS\",\"18.04-LTS\"."
  }
}

variable "location" {
  type        = string
  default     = "westus"
  description = "Enter the location for all resources."
}
