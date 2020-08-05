# Defining the local variables
locals {
  bastion-subnet-name = "AzureBastionSubnet"
  public-ip-address-name = lower(join("", ["bastion-host-name","-pip"]))
  nsg-name = lower(join("", ["bastion-host-name", "-nsg"]))
}

# Resource Group for provisioning new resources
resource "azurerm_resource_group" "arg-01" {
  count = var.vnet-new-or-existing == "new" ? 1 : 0
  name = var.resourcegroupname
  location = var.rg-location
}

# Public IP for new resource group
resource "azurerm_public_ip" "apip-01" {
  count = var.vnet-new-or-existing == "new" ? 1 : 0
  name = local.public-ip-address-name
  location = var.rg-location
  resource_group_name = azurerm_resource_group.arg-01.*.name[count.index]
  allocation_method = "Static"
  sku = "standard"
}

# Public IP for existing resource group
resource "azurerm_public_ip" "apip-01-existing" {
  count = var.vnet-new-or-existing == "existing" ? 1 : 0
  name = local.public-ip-address-name
  location = data.azurerm_virtual_network.vnet.*.location[count.index]
  resource_group_name = data.azurerm_virtual_network.vnet.*.resource_group_name[count.index]
  allocation_method = "Static"
  sku = "standard"
}

# Network security group and security rule for new virtual network
resource "azurerm_network_security_group" "ansg-01" {
  count = var.vnet-new-or-existing == "new" ? 1 : 0
  name = local.nsg-name
  location = var.rg-location
  resource_group_name = azurerm_resource_group.arg-01.*.name[count.index]
  security_rule {
    name                       = "bastion-in-allow"
    priority                   = 100
    access                     = "allow"
    protocol                   = "Tcp"
    direction                  = "inbound"
    source_address_prefix      = "internet"
    destination_address_prefix = "*"
    source_port_range          = "*"
    destination_port_range     = "443"
  }
  security_rule {
    name                       = "bastion-control-in-allow"
    priority                   = 120
    access                     = "allow"
    protocol                   = "Tcp"
    direction                  = "inbound"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["443", "4443"]
  }
  security_rule {
    name                       = "bastion-in-deny"
    priority                   = 900
    access                     = "deny"
    protocol                   = "*"
    direction                  = "inbound"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
  }
  security_rule {
    name                       = "bastion-vnet-out-allow"
    priority                   = 100
    access                     = "allow"
    protocol                   = "Tcp"
    direction                  = "outbound"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "3389"]
  }
  security_rule {
    name                       = "bastion-azure-out-allow"
    priority                   = 120
    access                     = "allow"
    protocol                   = "Tcp"
    direction                  = "outbound"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureCloud"
    source_port_range          = "*"
    destination_port_range     = "443"
  }
}

# Network security group and security rule for existing virtual network
resource "azurerm_network_security_group" "ansg-01-existing" {
  count = var.vnet-new-or-existing == "existing" ? 1 : 0
  name = local.nsg-name
  location = data.azurerm_virtual_network.vnet.*.location[count.index]
  resource_group_name = data.azurerm_virtual_network.vnet.*.resource_group_name[count.index]
  security_rule {
    name                       = "bastion-in-allow"
    priority                   = 100
    access                     = "allow"
    protocol                   = "Tcp"
    direction                  = "inbound"
    source_address_prefix      = "internet"
    destination_address_prefix = "*"
    source_port_range          = "*"
    destination_port_range     = "443"
  }
  security_rule {
    name                       = "bastion-control-in-allow"
    priority                   = 120
    access                     = "allow"
    protocol                   = "Tcp"
    direction                  = "inbound"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["443", "4443"]
  }
  security_rule {
    name                       = "bastion-in-deny"
    priority                   = 900
    access                     = "deny"
    protocol                   = "*"
    direction                  = "inbound"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
  }
  security_rule {
    name                       = "bastion-vnet-out-allow"
    priority                   = 100
    access                     = "allow"
    protocol                   = "Tcp"
    direction                  = "outbound"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "3389"]
  }
  security_rule {
    name                       = "bastion-azure-out-allow"
    priority                   = 120
    access                     = "allow"
    protocol                   = "Tcp"
    direction                  = "outbound"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureCloud"
    source_port_range          = "*"
    destination_port_range     = "443"
  }
}

# Creating new Virtual Network
resource "azurerm_virtual_network" "vnet-01" {
  count = var.vnet-new-or-existing == "new" ? 1 : 0
  name = var.vnet-name
  location = azurerm_resource_group.arg-01.*.location[count.index]
  resource_group_name =  azurerm_resource_group.arg-01.*.name[count.index]
  address_space = [var.vnet-ip-prefix]
}

# Creating subnet under new virtual network
resource "azurerm_subnet" "asnet-01" {
  count = var.vnet-new-or-existing == "new" ? 1 : 0
  name = local.bastion-subnet-name
  resource_group_name = azurerm_resource_group.arg-01.*.name[count.index]
  virtual_network_name = azurerm_virtual_network.vnet-01.*.name[count.index]
  address_prefixes = [var.bastion-subnet-ip-prefix]
}

# Associate subnet and network security group
resource "azurerm_subnet_network_security_group_association" "asnsga-01" {
  count = var.vnet-new-or-existing == "new" ? 1 : 0
  subnet_id            = azurerm_subnet.asnet-01.*.id[count.index]
  network_security_group_id = azurerm_network_security_group.ansg-01.*.id[count.index]
}

# Using existing virtual network
data "azurerm_virtual_network" "vnet" {
  count = var.vnet-new-or-existing == "existing" ? 1: 0
  name  = var.vnetname-existing
  resource_group_name = var.existing-rg  
} 

# Creating subnet in existing virtual network
resource "azurerm_subnet" "asnet-existing-01" {
  count = var.vnet-new-or-existing == "existing" ? 1: 0
  name = local.bastion-subnet-name
  resource_group_name = data.azurerm_virtual_network.vnet.*.resource_group_name[count.index]
  virtual_network_name = data.azurerm_virtual_network.vnet.*.name[count.index]
  address_prefixes = [var.bastion-subnet-ip-prefix]
}

# Associate subnet and network security group
resource "azurerm_subnet_network_security_group_association" "asnsga-01-existing" {
  count = var.vnet-new-or-existing == "existing" ? 1 : 0
  subnet_id                 = azurerm_subnet.asnet-existing-01.*.id[count.index]
  network_security_group_id = azurerm_network_security_group.ansg-01-existing.*.id[count.index]
}

# Creating bastion host for new virtual network
resource "azurerm_bastion_host" "bastion-01-new" {
  count = var.vnet-new-or-existing == "new" ? 1 : 0
  name                = var.bastion-host-name
  resource_group_name = azurerm_resource_group.arg-01.*.name[count.index]
  location            = var.rg-location

  ip_configuration {
    name                 = "ipconf"
    subnet_id            = azurerm_subnet.asnet-01.*.id[count.index]
    public_ip_address_id = azurerm_public_ip.apip-01.*.id[count.index]
  }
} 

# Creating bastion host for existing virtual network
resource "azurerm_bastion_host" "baiston-01-existing" {
  count = var.vnet-new-or-existing == "existing" ? 1 : 0
  name                = var.bastion-host-name
  resource_group_name = data.azurerm_virtual_network.vnet.*.resource_group_name[count.index]
  location = data.azurerm_virtual_network.vnet.*.location[count.index]

  ip_configuration {
    name                 = "ipconf"
    subnet_id            = azurerm_subnet.asnet-existing-01.*.id[count.index]
    public_ip_address_id = azurerm_public_ip.apip-01-existing.*.id[count.index]
  }
}
