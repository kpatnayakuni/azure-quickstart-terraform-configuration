# Defining the local variables
locals {
  dataDiskSize             = "1024"
  dataDisksCount           = "5"
  virtualNetworkName       = lower(join("", [var.virtualMachineName, "-vnet"]))
  subnetName               = lower(join("", [var.virtualMachineName, "-subnet"]))
  imagePublisher           = "MicrosoftWindowsServer"
  imageOffer               = "WindowsServer"
  OSDiskName               = lower(join("", [var.virtualMachineName, "OSDisk"]))
  addressPrefix            = "10.2.3.0/24"
  subnetPrefix             = "10.2.3.0/24"
  publicIPAddressType      = "Dynamic"
  networkInterfaceName     = lower(join("", [var.virtualMachineName]))
  publicIpAddressName      = lower(join("", [var.virtualMachineName, "-ip"]))
  networkSecurityGroupName = lower(join("", [local.subnetName, "-nsg"]))
}

# Resource Group
resource "azurerm_resource_group" "arg-01" {
  name     = var.resourceGroupName
  location = var.location
}

# Public IP
resource "azurerm_public_ip" "apip-01" {
  name                = local.publicIpAddressName
  resource_group_name = azurerm_resource_group.arg-01.name
  location            = azurerm_resource_group.arg-01.location
  allocation_method   = local.publicIPAddressType
  sku                 = "Basic"
  ip_version          = "IPv4"
}

# Network Security group
resource "azurerm_network_security_group" "ansg-01" {
  name                = local.networkSecurityGroupName
  resource_group_name = azurerm_resource_group.arg-01.name
  location            = azurerm_resource_group.arg-01.location
  security_rule {
    name                       = "default-allow-3389"
    priority                   = 1000
    access                     = "Allow"
    direction                  = "Inbound"
    destination_port_range     = 3389
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
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

# Virtual Machine
resource "azurerm_windows_virtual_machine" "avm-01" {
  name                  = var.virtualMachineName
  resource_group_name   = azurerm_resource_group.arg-01.name
  location              = azurerm_resource_group.arg-01.location
  size                  = var.virtualMachineSize
  network_interface_ids = [azurerm_network_interface.anic-01.id]
  admin_username        = var.adminUsername
  admin_password        = var.adminPassword
  os_disk {
    name                 = local.OSDiskName
    caching              = "ReadWrite"
    storage_account_type = var.disktype[0]
    disk_size_gb         = 128
  }
  source_image_reference {
    publisher = local.imagePublisher
    offer     = local.imageOffer
    sku       = var.windowsOSVersion[0]
    version   = "latest"
  }
}

# Managed disk
resource "azurerm_managed_disk" "amd-01" {
  count                = local.dataDisksCount
  name                 = "${var.virtualMachineName}DataDisks${count.index}"
  resource_group_name  = azurerm_resource_group.arg-01.name
  location             = azurerm_resource_group.arg-01.location
  create_option        = "Empty"
  disk_size_gb         = local.dataDiskSize
  storage_account_type = var.disktype[0]
}

# Attaching managed disk to virtual machine
resource "azurerm_virtual_machine_data_disk_attachment" "adattach-01" {
  count              = local.dataDisksCount
  managed_disk_id    = element(azurerm_managed_disk.amd-01.*.id, count.index)
  virtual_machine_id = azurerm_windows_virtual_machine.avm-01.id
  caching            = "ReadWrite"
  lun                = count.index
}
