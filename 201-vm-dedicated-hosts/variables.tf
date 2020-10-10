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
  default     = "centralus"
  description = "Location for all resources"
}

variable "numberOfZoness" {
  type        = string
  default     = 2
  description = "How many Zone to use. Use 0 for non zonal deployment."
}

variable "numberofHostsPerZone" {
  type        = string
  default     = 2
  description = "How many hosts to create per zone."
}

variable "numberOfFDs" {
  type        = string
  default     = 2
  description = "How many fault domains to use."
}

variable "dhgNamePrefix" {
  type        = string
  default     = "myHostGroup"
  description = "Name (prefix) for your host group."
}

variable "dhNamePrefix" {
  type        = string
  default     = "myHost"
  description = "Name (prefix) for your host."
}

variable "dhSKU" {
  type        = string
  default     = "DSv3-Type1"
  description = "The type (family and generation) for your host."
}
