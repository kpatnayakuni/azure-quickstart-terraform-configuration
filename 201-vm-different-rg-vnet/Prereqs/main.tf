# Defining the local variables
locals {
    existingVirtualNetworkName = "existing-vnet"
    existingSubnetName = "existing-subnet-1"
}

# Resource Group
resource "azurerm_resource_group" "arg-01" {
  name     = var.resourceGroupName
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "avn-01" {
  name                = local.existingVirtualNetworkName
  resource_group_name = azurerm_resource_group.arg-01.name
  location            = azurerm_resource_group.arg-01.location
  address_space       = ["10.0.0.0/16"]
  tags = {
    displayName =  "Virtual Network"
  }
}

# Subnet
resource "azurerm_subnet" "as-01" {
  name                 = local.existingSubnetName
  resource_group_name  = azurerm_resource_group.arg-01.name
  virtual_network_name = azurerm_virtual_network.avn-01.name
  address_prefixes     = ["10.0.1.0/24"]
}

#Output
# Existing virtualnetwork 
output "virtualNetworkName" {
  value = local.existingVirtualNetworkName
}

# Existing subnet 
output "subnet1Name" {
  value = local.existingSubnetName
}

# Existing resource group name 
output "virtualNetworkResourceGroup" {
  value = var.resourceGroupName
}
