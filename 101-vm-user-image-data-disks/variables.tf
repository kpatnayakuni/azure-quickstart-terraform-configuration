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

variable "customVmName" {
  type        = string
  default     = "demovm"
  description = "This is the name of the your VM."
}

variable "bootDiagnosticsStorageAccountName" {
  type        = string
  default     = "bootstoragename"
  description = "This is the name of the your storage account."
}

variable "bootDiagnosticsStorageAccountResourceGroupName" {
  type        = string
  default     = "test-rg"
  description = "Resource group of the existing storage account."
}

variable "osDiskVhdUri" {
  type        = string
  default     = "https://demostorageaugust.blob.core.windows.net/democontainer/azvmimage.vhd"
  description = "URI in Azure storage of the blob (VHD) that you want to use for the OS disk. eg. https://mystorageaccount.blob.core.windows.net/osimages/osimage.vhd."
}

variable "dataDiskVhdUri" {
  type        = string
  default     = "https://demostorageaugust.blob.core.windows.net/democontainer/imgdatadisk.vhd"
  description = "RI in Azure storage of the blob (VHD) that you want to use for the data disk. eg. https://mystorageaccount.blob.core.windows.net/dataimages/dataimage.vhd"
}

variable "diskStorageType" {
  type        = list
  default     = ["Standard_LRS", "Premium_LRS"]
  description = "Storage disk type."
}

variable "dnsLabelPrefix" {
  type        = string
  default     = "demodnsaugust"
  description = "DNS Label for the Public IP. Must be lowercase. It should match with the following regular expression: ^[a-z][a-z0-9-]{1,61}[a-z0-9]$ or it will raise an error."
}

variable "adminUsername" {
  type        = string
  default     = "demo_user"
  description = "User Name for the Virtual Machine."
}

variable "adminPassword" {
  type        = string
  description = "Password for the Virtual Machine."
}

variable "osType" {
  type        = list
  default     = ["Windows", "Linux"]
  description = "This is the OS that your VM will be running."
}

variable "vmSize" {
  type        = string
  default     = "Standard_DS1_v2"
  description = "This is the size of your VM."
}

variable "vnet-new-or-existing" {
  type        = string
  description = "Select if this template needs a new VNet or will reference an existing VNet"
}

variable "newVnetName" {
  type        = string
  default     = "new-vnet"
  description = "New VNet Name."
}

variable "existingVnetName" {
  type        = string
  default     = "existing-vnet"
  description = "Existing VNet Name."
}

variable "newsubnetName" {
  type        = string
  default     = "newsubnet"
  description = "New subnet Name."
}

variable "existingsubnetName" {
  type        = string
  default     = "defaault"
  description = "Existing subnet Name."
}

variable "existingVnetResourceGroupName" {
  type        = string
  default     = "test-rg"
  description = "Resource group of the existing VNET"
}
