variable "resource_group_name" {
    type = "string"
    default = "terraform-rg"
    description = "Enter the resource group name"
}

variable "storage_account_type" {
    type = "string"
    default = "Standard"
    description = "Storage Account type for the VM and VM diagnostic storage"
}
variable "location" {
    type = "string"
    default = "westus"
    description = "Enter the location for all resources."
}

resource "random_string" "asaname-01" {
  length = 16
  special = "false"
}

resource "azurerm_resource_group" "arg-01" {
  name      = "${var.resource_group_name}"
  location  = "${var.location}"
}

resource "azurerm_storage_account" "asa-01" {
  name = lower(join("", ["diag", "${random_string.asaname-01.result}"]))
  resource_group_name = "${azurerm_resource_group.arg-01.name}"
  location = "${azurerm_resource_group.arg-01.location}"
  account_replication_type = "LRS"
  account_tier = "${var.storage_account_type}"
}

output "randomString" {
    value = lower("diag${random_string.asaname-01.result}")
}