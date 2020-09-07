# Variable declaration
variable "resourceGroupName" {
  type        = string
  description = "Resource Group for this deployment."
}

variable "location" {
  type        = string
  description = "Location for all resources"
}

variable "customVmName" {
  type        = string
  description = "This is the name of the your VM."
}

variable "bootDiagnosticsStorageAccountName" {
  type        = string
  description = "This is the name of the your storage account."
}

variable "bootDiagnosticsStorageAccountResourceGroupName" {
  type        = string
  description = "Resource group of the existing storage account."
}

variable "osDiskVhdUri" {
  type        = string
  description = "URI in Azure storage of the blob (VHD) that you want to use for the OS disk. eg. https://mystorageaccount.blob.core.windows.net/osimages/osimage.vhd."
}

variable "dataDiskVhdUri" {
  type        = string
  description = "RI in Azure storage of the blob (VHD) that you want to use for the data disk. eg. https://mystorageaccount.blob.core.windows.net/dataimages/dataimage.vhd"
}

variable "diskStorageType" {
  type        = list
  description = "Storage disk type."
}

variable "dnsLabelPrefix" {
  type        = string
  description = "DNS Label for the Public IP. Must be lowercase. It should match with the following regular expression: ^[a-z][a-z0-9-]{1,61}[a-z0-9]$ or it will raise an error."
}

variable "adminUsername" {
  type        = string
  description = "User Name for the Virtual Machine."
}

variable "adminPassword" {
  type        = string
  description = "Password for the Virtual Machine."
}

variable "osType" {
  type        = list
  description = "This is the OS that your VM will be running."
}

variable "vmSize" {
  type        = string
  description = "This is the size of your VM."
}

variable "newVnetName" {
  type        = string
  description = "New VNet Name."
}

variable "newsubnetName" {
  type        = string
  description = "New subnet Name."
}

variable "addressPrefix" {
  type        = string
  description = "Address prefix for new virtual network"
}

variable "subnetPrefix" {
  type        = string
  description = "Subnet prefix"
}

variable "publicIPAddressType" {
  type        = string
  description = "Public IP address type"
}

variable "imageName" {
  type        = string
  description = "image name"
}
