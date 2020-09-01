# Defining the local variables
locals {
  storageAccountName       = lower(join("", [random_string.asaname-01.result, "satagsvm"]))
  imagePublisher           = "MicrosoftWindowsServer"
  imageOffer               = "WindowsServer"
  nicName                  = "myVMNic"
  addressPrefix            = "10.0.0.0/16"
  subnetName               = "Subnet"
  subnetPrefix             = "10.0.0.0/24"
  storageAccountType       = "Standard_LRS"
  storageAccountTier       = "Standard"
  storagereplicationType   = "LRS"
  publicIPAddressName      = "myPublicIP"
  publicIPAddressType      = "Dynamic"
  vmName                   = "MyVM"
  virtualNetworkName       = "MyVNET"
  networkSecurityGroupName = "default-NSG"
  dnsLabelPrefix           = lower(join("", ["vm-", random_string.vmd.result]))
  osDiskName               = join("", [local.vmName, "_OsDisk_1_", lower(random_string.avmosd-01.result)])
}

# Generate random string for Storage account
resource "random_string" "asaname-01" {
  length  = 8
  special = "false"
}

# Generate random string for dns 
resource "random_string" "vmd" {
  length  = 32
  special = "false"
}

# Generate random string for OS disk
resource "random_string" "avmosd-01" {
  length  = 32
  special = "false"
}

# Resource Group
resource "azurerm_resource_group" "arg-01" {
  name     = var.resourceGroupName
  location = var.location
}

# Storage account
resource "azurerm_storage_account" "asa-01" {
  name                = local.storageAccountName
  resource_group_name = azurerm_resource_group.arg-01.name
  location            = azurerm_resource_group.arg-01.location
  account_kind        = "Storage"
  account_tier        = local.storageAccountTier
  account_replication_type = local.storagereplicationType
  tags = {
    Department   = var.departmentName
    Application  = var.applicationName
    "Created By" = var.createdBy
  }
}

# Public IP
resource "azurerm_public_ip" "apip-01" {
  name                = local.publicIPAddressName
  resource_group_name = azurerm_resource_group.arg-01.name
  location            = azurerm_resource_group.arg-01.location
  allocation_method   = local.publicIPAddressType
  domain_name_label   = local.dnsLabelPrefix
  tags = {
    Department   = var.departmentName
    Application  = var.applicationName
    "Created By" = var.createdBy
  }
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
  tags = {
    Department   = var.departmentName
    Application  = var.applicationName
    "Created By" = var.createdBy
  }
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
  tags = {
    Department   = var.departmentName
    Application  = var.applicationName
    "Created By" = var.createdBy
  }
}

# Virtual Machine
resource "azurerm_windows_virtual_machine" "avm-01" {
  name                  = local.vmName
  resource_group_name   = azurerm_resource_group.arg-01.name
  location              = azurerm_resource_group.arg-01.location
  size                  = var.vmSize
  network_interface_ids = [azurerm_network_interface.anic-01.id]
  admin_username        = var.adminUsername
  admin_password        = var.adminPassword
  source_image_reference {
    publisher = local.imagePublisher
    offer     = local.imageOffer
    sku       = var.windowsOSVersion[7]
    version   = "latest"
  }
  os_disk {
    name                 = local.osDiskName
    caching              = "ReadWrite"
    storage_account_type = local.storageAccountType
  }
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.asa-01.primary_blob_endpoint
  }
  tags = {
    Department   = var.departmentName
    Application  = var.applicationName
    "Created By" = var.createdBy
  }
}
