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
  description = "Location for the VM, only certain regions support zones during preview."
}

variable "adminUsername" {
  type        = string
  default     = "demouser"
  description = "Username for the Virtual Machine."
}

variable "authenticationType" {
  type        = string
  default     = "password"
  description = "Type of authentication to use on the Virtual Machine. SSH key is recommended."
  validation {
    condition     = var.authenticationType == "sshPublicKey" || var.authenticationType == "password"
    error_message = "Authentication type should be either \"ssh\" or \"password\"."
  }
}

variable "adminPasswordOrKey" {
  type        = string
  default     = "Abcd@123"
  description = "SSH Key or password for the Virtual Machine. SSH key is recommended."
}

variable "osType" {
  type        = string
  default     = "Windows"
  description = "This is the OS that your VM will be running"
  validation {
    condition     = contains(["Windows", "Linux"], var.osType)
    error_message = "VM should be either Windows or Linux."
  }
}

variable "osDiskVhdUri" {
  type        = string
  default     = "https://demostorageaugust.blob.core.windows.net/democontainer/azvmimage.vhd"
  description = "Uri of the your user image"
}

variable "vmSize" {
  type        = string
  default     = "Standard_D2s_v3"
  description = "Size of the VM, this sample uses a Gen 2 VM, see: https://docs.microsoft.com/en-us/azure/virtual-machines/windows/generation-2#generation-2-vm-sizes"
}

variable "vmName" {
  type        = string
  default     = "vmFromImage"
  description = "Name of the VM"
}
