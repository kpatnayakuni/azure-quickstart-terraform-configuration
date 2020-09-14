# Defining the local variables
locals {
  vNetName                  = join("", [var.projectName, "-vnet"])
  vNetAddressPrefixes       = "10.0.0.0/16"
  vNetSubnetName            = "default"
  vNetSubnetAddressPrefix   = "10.0.0.0/24"
  vmName                    = join("", [var.projectName, "-vm"])
  publicIPAddressName       = join("", [var.projectName, "-ip"])
  networkInterfaceName      = join("", [var.projectName, "-nic"])
  networkSecurityGroupName  = join("", [var.projectName, "-nsg"])
  networkSecurityGroupName2 = join("", [local.vNetSubnetName, "-nsg"])
}

# Resource Group
resource "azurerm_resource_group" "arg-01" {
  name     = var.resourceGroupName
  location = var.location
}

# Network security group with SSH allow rule
resource "azurerm_network_security_group" "ansg-01" {
  name                = local.networkSecurityGroupName
  resource_group_name = azurerm_resource_group.arg-01.name
  location            = azurerm_resource_group.arg-01.location
  security_rule {
    name                       = "ssh_rule"
    priority                   = 123
    protocol                   = "TCP"
    access                     = "Allow"
    direction                  = "Inbound"
    destination_port_range     = "22"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "Locks inbound down to ssh default port 22."
  }
}

# Public IP
resource "azurerm_public_ip" "apip-01" {
  name                = local.publicIPAddressName
  resource_group_name = azurerm_resource_group.arg-01.name
  location            = azurerm_resource_group.arg-01.location
  allocation_method   = "Dynamic"
  sku                 = "basic"
}

# Simple Network Security Group for subnet
resource "azurerm_network_security_group" "ansg-02" {
  name                = local.networkSecurityGroupName2
  resource_group_name = azurerm_resource_group.arg-01.name
  location            = azurerm_resource_group.arg-01.location
  security_rule {
    name                       = "default-allow-22"
    priority                   = 1000
    protocol                   = "TCP"
    access                     = "Allow"
    direction                  = "Inbound"
    destination_port_range     = "22"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "avn-01" {
  name                = local.vNetName
  resource_group_name = azurerm_resource_group.arg-01.name
  location            = azurerm_resource_group.arg-01.location
  address_space       = [local.vNetAddressPrefixes]
}

# Subnet
resource "azurerm_subnet" "as-01" {
  name                 = local.vNetSubnetName
  resource_group_name  = azurerm_resource_group.arg-01.name
  virtual_network_name = azurerm_virtual_network.avn-01.name
  address_prefixes     = [local.vNetSubnetAddressPrefix]
}

# Associate subnet and network security group 
resource "azurerm_subnet_network_security_group_association" "asnsga-01" {
  subnet_id                 = azurerm_subnet.as-01.id
  network_security_group_id = azurerm_network_security_group.ansg-02.id
}

# Network interface with IP configuration
resource "azurerm_network_interface" "anic-01" {
  name                = local.networkInterfaceName
  resource_group_name = azurerm_resource_group.arg-01.name
  location            = azurerm_resource_group.arg-01.location
  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.apip-01.id
    subnet_id                     = azurerm_subnet.as-01.id
  }
}

# Create VM with authentication type SSH 
resource "azurerm_linux_virtual_machine" "avm-01" {
  name                  = local.vmName
  resource_group_name   = azurerm_resource_group.arg-01.name
  location              = azurerm_resource_group.arg-01.location
  network_interface_ids = [azurerm_network_interface.anic-01.id]
  size                  = "Standard_D2s_v3"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  admin_username                  = var.adminUsername
  disable_password_authentication = true
  admin_ssh_key {
    username   = var.adminUsername
    public_key = file("~/.ssh/id_rsa.pub")
  }
}

## Output
# Username 
output "adminUsername" {
  value = var.adminUsername
}
