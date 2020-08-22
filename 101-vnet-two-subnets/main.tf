# Resource Group
resource "azurerm_resource_group" "arg-01" {
	name        = var.resourceGroupName
	location    = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "avn-01" {
	name                = var.vnetName
	resource_group_name = azurerm_resource_group.arg-01.name
	location            = azurerm_resource_group.arg-01.location
	address_space       = [var.vnetAddressPrefix]
}

# Subnet 1
resource "azurerm_subnet" "as-01" {
	name                  = var.subnet1Name
	resource_group_name   = azurerm_resource_group.arg-01.name
	virtual_network_name  = azurerm_virtual_network.avn-01.name
	address_prefixes      = [var.subnet1Prefix]
}

# Subnet 2
resource "azurerm_subnet" "as-02" {
	name                  = var.subnet2Name
	resource_group_name   = azurerm_resource_group.arg-01.name
	virtual_network_name  = azurerm_virtual_network.avn-01.name
	address_prefixes      = [var.subnet2Prefix]
}
