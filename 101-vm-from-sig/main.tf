# Defining the local variables
locals {
  nicName                  = "myVMNic"
  vmName                   = "myVMFromGalleryImageVersion"
  virtualNetworkName       = "MyVNET"
  publicIPAddressName      = "myPublicIP"
  addressPrefix            = "10.0.0.0/16"
  subnetName               = "Subnet"
  subnetPrefix             = "10.0.0.0/24"
  networkSecurityGroupName = join("", [local.subnetName, "-nsg"])
}

# Resource Group
resource "azurerm_resource_group" "arg-01" {
  name     = var.resourceGroupName
  location = var.location
}

# Public IP
resource "azurerm_public_ip" "apip-01" {
  name                = local.publicIPAddressName
  resource_group_name = azurerm_resource_group.arg-01.name
  location            = azurerm_resource_group.arg-01.location
  allocation_method   = "Dynamic"
  domain_name_label   = var.dnsLabelPrefix
}

# Network security group with SSH allow rule
resource "azurerm_network_security_group" "ansg-01" {
  name                = local.networkSecurityGroupName
  resource_group_name = azurerm_resource_group.arg-01.name
  location            = azurerm_resource_group.arg-01.location

  dynamic "security_rule" {
    for_each = var.os_type == "linux" ? [1] : []
    content {
      name                       = "default-allow-22"
      priority                   = 1000
      access                     = "Allow"
      direction                  = "Inbound"
      destination_port_range     = "22"
      protocol                   = "Tcp"
      source_port_range          = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
  dynamic "security_rule" {
    for_each = var.os_type == "windowds" ? [1] : []
    content {
      name                       = "default-allow-3389"
      priority                   = 1001
      access                     = "Allow"
      direction                  = "Inbound"
      destination_port_range     = "3389"
      protocol                   = "Tcp"
      source_port_range          = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
}

# Virtual Network
resource "azurerm_virtual_network" "avn-01" {
  name                = local.virtualNetworkName
  resource_group_name = azurerm_resource_group.arg-01.name
  location            = azurerm_resource_group.arg-01.location
  address_space       = [local.addressPrefix]
}

# Subnet
resource "azurerm_subnet" "as-01" {
  name                 = local.subnetName
  resource_group_name  = azurerm_resource_group.arg-01.name
  virtual_network_name = azurerm_virtual_network.avn-01.name
  address_prefixes     = [local.subnetPrefix]
}

# Associate subnet and network security group 
resource "azurerm_subnet_network_security_group_association" "asnsga-01" {
  subnet_id                 = azurerm_subnet.as-01.id
  network_security_group_id = azurerm_network_security_group.ansg-01.id
}

# Network interface with IP configuration
resource "azurerm_network_interface" "anic-01" {
  name                = local.nicName
  resource_group_name = azurerm_resource_group.arg-01.name
  location            = azurerm_resource_group.arg-01.location
  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.apip-01.id
    subnet_id                     = azurerm_subnet.as-01.id
  }
}

# Information about existing shared image version
data "azurerm_shared_image_version" "asgi" {
  name                = var.galleryImageVersionName
  image_name          = var.galleryImageDefinitionName
  gallery_name        = var.galleryName
  resource_group_name = "sig-rg"
}

# Virtual machine - Linux
resource "azurerm_linux_virtual_machine" "avm-ssh-01" {
  count                           = var.os_type == "linux" ? 1 : 0
  name                            = local.vmName
  resource_group_name             = azurerm_resource_group.arg-01.name
  location                        = azurerm_resource_group.arg-01.location
  size                            = "Standard_A1"
  network_interface_ids           = [azurerm_network_interface.anic-01.id]
  admin_username                  = var.adminUsername
  admin_password                  = var.adminPassword
  disable_password_authentication = false
  source_image_id                 = data.azurerm_shared_image_version.asgi.id
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

# Virtual Machine - Windows
resource "azurerm_windows_virtual_machine" "avm-01" {
  count                 = var.os_type == "windows" ? 1 : 0
  name                  = local.vmName
  computer_name         = "myVm"
  resource_group_name   = azurerm_resource_group.arg-01.name
  location              = azurerm_resource_group.arg-01.location
  size                  = "Standard_A1"
  admin_username        = var.adminUsername
  admin_password        = var.adminPassword
  network_interface_ids = [azurerm_network_interface.anic-01.id]
  source_image_id       = data.azurerm_shared_image_version.asgi.id
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

# Hostname 
output "hostname" {
  value = azurerm_public_ip.apip-01.fqdn
}
