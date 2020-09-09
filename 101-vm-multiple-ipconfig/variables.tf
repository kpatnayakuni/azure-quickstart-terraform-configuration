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
  description = "enter subscription id."
}

variable "tf_var_arm_client_id" {
  description = "Enter Client ID."
}

variable "tf_var_arm_client_secret" {
  description = "Enter secret"
}

variable "tf_var_arm_tenant_id" {
  description = "Enter tenant ID."
}

variable "resourceGroupName" {
  type        = string
  default     = "demo-rg"
  description = "Resource Group for this deployment."
}

variable "location" {
  type = string
  default = "westus"
  description = "Location for all resources."
}

variable  "adminUsername" {
  type = string
  description = "Admin username"
}

variable "adminPassword" {
  type = string
  description = "Admin password"
}

variable "dnsLabelPrefix" {
  type = string
  description = "DNS for PublicIPAddressName1"
}

variable "dnsLabelPrefix1" {
  type = string
  description = "DNS for PublicIPAddressName2"
}

variable "OSVersion" {
  type = string
  description = "The Windows/Linux version for the VM. This will pick a fully patched image of this given Windows/Linux version."
  validation {
    condition = contains(["2012-Datacenter","2012-R2-Datacenter","2016-Nano-Server","2016-Datacenter-with-Containers","2016-Datacenter","16.04.0-LTS","7.2"], var.OSVersion)
    error_message = "The Windows/Linux version for the VM are 2012-Datacenter,2012-R2-Datacenter,2016-Nano-Server,2016-Datacenter-with-Containers,2016-Datacenter,16.04.0-LTS,7.2."
  }
}

variable "imagePublisher" {
  type = map
  default = {
    "2012-Datacenter" = "MicrosoftWindowsServer"
    "2012-R2-Datacenter" = "MicrosoftWindowsServer"
    "2016-Nano-Server" = "MicrosoftWindowsServer"
    "2016-Datacenter-with-Containers" = "MicrosoftWindowsServer"
    "2016-Datacenter" = "MicrosoftWindowsServer"
    "16.04.0-LTS" = "Canonical"
    "7.2" = "RedHat"
  }
}

variable "imageOffer" {
  type = map
  default = {
    "2012-Datacenter" = "WindowsServer"
    "2012-R2-Datacenter" = "WindowsServer"
    "2016-Nano-Server" = "WindowsServer"
    "2016-Datacenter-with-Containers" = "WindowsServer"
    "2016-Datacenter" = "WindowsServer"
    "16.04.0-LTS" = "UbuntuServer"
    "7.2" = "RHEL"
  }
}
