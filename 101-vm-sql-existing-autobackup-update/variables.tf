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
  description = "Existing resource Group for this deployment."
}

variable "location" {
  type        = string
  default     = "westus"
  description = "Location for the VM, only certain regions support zones during preview."
}

variable "existingVirtualMachineName" {
  type        = string
  description = "Existing SQL Server virtual machine name."
}

variable "sqlAutobackupRetentionPeriod" {
  default     = 2
  description = "SQL Server Auto Backup Retention Period."
  validation {
    condition     = var.sqlAutobackupRetentionPeriod <= 30
    error_message = "Retention persiod is (30 or less)."
  }
}

variable "sqlAutobackupStorageAccountName" {
  type        = string
  description = "SQL Server Auto Backup Storage Account Name"
}

variable "sqlAutobackupEncryptionPassword" {
  type        = string
  description = "SQL Server Auto Backup Encryption Password"
}
