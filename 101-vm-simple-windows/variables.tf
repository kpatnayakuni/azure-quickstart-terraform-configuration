provider "azurerm" {
    features {}
     subscription_id = var.tf_var_arm_subscription_id
     client_id  = var.tf_var_arm_client_id
     client_secret = var.tf_var_arm_client_secret
     tenant_id = var.tf_var_arm_tenant_id
}
#TF_VAR_ARM_SUBSCRIPTION_ID
#arm_client_id

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
    description = "Resource Group for this deployment."
}

variable "location" {
    type        = string
    description = "Location for all resources"
}

variable "adminUsername" {
    type        = string
    description = "Username for the Virtual Machine."
}

variable "adminPassword" {
    type        = string
    description = "Password for the Virtual Machine."
}

variable "dnsLabelPrefix" {
    type        = string
    description = "Unique DNS Name for the Public IP used to access the Virtual Machine."
}

variable "windowsOSVersion" {
    type        = list
    default     = ["2016-Datacenter","2008-R2-SP1","2012-Datacenter","2012-R2-Datacenter","2016-Nano-Server","2016-Datacenter-with-Containers","2019-Datacenter"]
    description = "The Windows version for the VM. This will pick a fully patched image of this given Windows version."
}

variable "vmSize" {
    type    = string
    default = "Standard_A2_v2"
    description = "Size of the virtual machine."
}