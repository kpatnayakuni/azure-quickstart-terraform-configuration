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
  default     = "demo"
  description = "Enter the resource group name of existing VM"
}

variable "location" {
  type        = string
  default     = "westus"
  description = "Location of existing VM"
}

variable "existingVirtualMachineName" {
  type =  string
description = "Existing SQL Server virtual machine name"
default = "ExistingWinVm"

}
variable "sqlAutopatchingDayOfWeek" {
  type    = string
  default = "Sunday"
  description = "SQL Server Auto Patching Day of A Week"
  validation {
    condition = contains(["Everyday","Never","Sunday", "Monday","Tuesday", "Wednesday","Thursday","Friday", "Saturday"],var.sqlAutopatchingDayOfWeek)
    error_message = "Variable \"sqlAutopatchingDayOfWeek\" accepts values from the following \"Everyday\",\"Never\",\"Sunday\",\"Monday\",\"Tuesday\", \"Wednesday\",\"Thursday\",\"Friday\",\"Saturday\"."
  }
}

variable "sqlAutopatchingStartHour" {
  description = "SQL Server Auto Patching Starting Hour"
  default = 2
  validation {
    condition = contains(range(0, 24), var.sqlAutopatchingStartHour)
    error_message = "Auto patching hours should be between 0-23."
  }
}

variable "sqlAutopatchingWindowDuration" {
  type = string
  default = "60"
  description = "SQL Server Auto Patching Duration Window in minutes"
  validation {
    condition  = contains(["30","60","90","120","150","180"],var.sqlAutopatchingWindowDuration)
    error_message = "Accepts values from \"30\",\"60\",\"90\",\"120\",\"150\",\"180\"."
  }
}
