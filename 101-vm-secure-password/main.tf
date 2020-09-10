# Defining the local variables
locals {
  storageAccountName            = lower(join("", [random_string.asaname-01.result, "sawinvm"]))
  imagePublisher                = "MicrosoftWindowsServer"
  imageOffer                    = "WindowsServer"
  nicName                       = "myVMNic"
  addressPrefix                 = "10.0.0.0/16"
  subnetName                    = "Subnet"
  subnetPrefix                  = "10.0.0.0/24"
  storageAccountType            = "Standard"
  storageAccountreplicationType = "LRS"
  publicIPAddressName           = "myPublicIP"
  publicIPAddressType           = "Dynamic"
  vmName                        = "SimpleWinVM"
  virtualNetworkName            = "MyVNET"
  networkSecurityGroupName      = join("", ["subnetName", "-nsg"])
}

# Generate random string for Storage account
resource "random_string" "asaname-01" {
  length  = 16
  special = "false"
}

# Fetch key vault  
data "azurerm_key_vault" "akv-01" {
  name                = var.AzkeyvaultName
  resource_group_name = var.Azkeyvault-rg
}

#Fetch value of secret "adminpassword"
data "azurerm_key_vault_secret" "akvs-01" {
  name         = var.AzSecretename
  key_vault_id = data.azurerm_key_vault.akv-01.id
}

# Resource Group
resource "azurerm_resource_group" "arg-01" {
  name     = var.resourceGroupName
  location = var.location
}

# Storage account
resource "azurerm_storage_account" "asa-01" {
  name                     = local.storageAccountName
  resource_group_name      = azurerm_resource_group.arg-01.name
  location                 = azurerm_resource_group.arg-01.location
  account_replication_type = local.storageAccountreplicationType
  account_tier             = local.storageAccountType
  account_kind             = "Storage"
}

# Public IP
resource "azurerm_public_ip" "apip-01" {
  name                = local.publicIPAddressName
  resource_group_name = azurerm_resource_group.arg-01.name
  location            = azurerm_resource_group.arg-01.location
  allocation_method   = local.publicIPAddressType
  domain_name_label   = var.dnsLabelPrefix
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

# Virtual Machine
resource "azurerm_windows_virtual_machine" "avm-01" {
  name                  = local.vmName
  resource_group_name   = azurerm_resource_group.arg-01.name
  location              = azurerm_resource_group.arg-01.location
  size                  = var.vmSize
  admin_username        = var.adminUsername
  admin_password        = data.azurerm_key_vault_secret.akvs-01.value
  network_interface_ids = [azurerm_network_interface.anic-01.id]
  source_image_reference {
    publisher = local.imagePublisher
    offer     = local.imageOffer
    sku       = var.windowsOSVersion
    version   = "latest"
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.asa-01.primary_blob_endpoint
  }
}

# Create Managed disk
resource "azurerm_managed_disk" "amd-01" {
  name                 = "${local.vmName}DataDisks"
  resource_group_name  = azurerm_resource_group.arg-01.name
  location             = azurerm_resource_group.arg-01.location
  create_option        = "Empty"
  disk_size_gb         = 1023
  storage_account_type = "Standard_LRS"
}

# Attaching managed disk to virtual machine
resource "azurerm_virtual_machine_data_disk_attachment" "adattach-01" {
  managed_disk_id    = azurerm_managed_disk.amd-01.id
  virtual_machine_id = azurerm_windows_virtual_machine.avm-01.id
  caching            = "ReadWrite"
  lun                = 0
}
