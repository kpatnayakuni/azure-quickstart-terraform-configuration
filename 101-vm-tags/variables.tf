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
  default     = "WestUS"
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

variable "windowsOSVersion" {
  type        = list
  default     = ["2016-Datacenter", "2016-Datacenter-Server-Core", "2016-Datacenter-Server-Core-smalldisk", "2016-Datacenter-smalldisk", "2016-Datacenter-with-Containers", "2016-Datacenter-with-RDSH", "2016-Datacenter-zhcn", "2019-Datacenter", "2019-Datacenter-Core", "2019-Datacenter-Core-smalldisk", "2019-Datacenter-Core-with-Containers", "2019-Datacenter-Core-with-Containers-smalldisk", "2019-datacenter-gensecond", "2019-Datacenter-smalldisk", "2019-Datacenter-with-Containers", "2019-Datacenter-with-Containers-smalldisk", "2019-Datacenter-zhcn", "Datacenter-Core-1803-with-Containers-smalldisk", "Datacenter-Core-1809-with-Containers-smalldisk", "Datacenter-Core-1903-with-Containers-smalldisk"]
  description = "The Windows version for the VM. This will pick a fully patched image of this given Windows version."
}

variable "departmentName" {
  type        = string
  default     = "MyDepartment"
  description = "Department Tag."
}

variable "applicationName" {
  type        = string
  default     = "MyApp"
  description = "Application Tag"
}

variable "createdBy" {
  type        = string
  default     = "MyName"
  description = "Created By Tag."
}

variable "vmSize" {
  type        = string
  default     = "Standard_D2_V3"
  description = "Size for the virtual machine."
}