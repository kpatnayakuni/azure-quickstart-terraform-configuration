# Variable declaration
variable "resourceGroupName" {
  type        = string
  description = "Enter the resource group name"
}

variable "vmName" {
  type        = string
  description = "The name of the VMe"
}

variable "vmsize" {
  type        = string
  description = "Size of the vm"

}
variable "adminUsername" {
  type        = string
  default     = "cloudguy"
  description = "The name of the administrator of the new VM. Exclusion list: 'admin','administrator'"
}

variable "adminPassword" {
  type        = string
  description = "The password for the administrator account of the new VM"
}

variable "location" {
  type        = string
  description = "Enter the location for all resources."
}

variable "virtualNetworkName" {
  type        = string
  description = "Name of the VNET"
}

variable "subnetName" {
  type        = string
  description = "Name of the subnet in the virtual network"
}

variable "addressPrefix" {
  type        = string
  description = "vNet address range"
}

variable "publicIPAddressName" {
  type        = string
  description = "public ip address name of VM"
}

variable "subnetAddressRange" {
  type        = string
  description = "subnet address range"
}

variable "dnsLabelPrefix" {
  type        = string
  description = "Unique public DNS prefix for the deployment. The fqdn will look something like '<dnsname>.westus.cloudapp.azure.com'. Up to 62 chars, digits or dashes, lowercase, should start with a letter: must conform to '^[a-z][a-z0-9-]{1,61}[a-z0-9]$'."
}

variable "networkSecurityGroupName" {
  type        = string
  description = "Name of the Network Security Group"
}
