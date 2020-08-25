# Authentication
provider "azurerm" {
    features {}
     subscription_id = var.tf_var_arm_subscription_id
     client_id  = var.tf_var_arm_client_id
     client_secret = var.tf_var_arm_client_secret
     tenant_id = var.tf_var_arm_tenant_id
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
    default     = "demo-rg1"
    description = "Resource Group for this deployment."
}

variable "location" {
    type        = string
    default     = "WestUS"
    description = "Location for all resources"
}

variable "adminUsername" {
    type        = string
    default     = "demo_user"
    description = "User name for the Virtual Machine."
}

variable "adminPassword" {
    type        = string
    description = "Password for the Virtual Machine."
}

variable "OSVersion" {
    type        = list
    default     = ["2016-Datacente","2016-Datacenter-Server-Core","2016-Datacenter-Server-Core-smalldisk","2016-Datacenter-smalldisk","2016-Datacenter-with-Containers","2016-Nano-Server"]
    description = "The Ubuntu version for the VM. This will pick a fully patched image of this given Ubuntu version.."
}

variable "numberOfDataDisks"{
    type = number
    default = 16
    description = "The number of dataDisks to be returned in the output array."
    validation {
        condition = var.numberOfDataDisks >= 1 && var.numberOfDataDisks <= 16
        error_message = "Enter the value between 1 and 16."
    }
}
