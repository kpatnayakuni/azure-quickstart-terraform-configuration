# Defining the local variables
locals {
  imageName           = "myCustomImage"
  publicIPAddressName = lower(join("", [var.customVmName, "IP"]))
  nicName             = lower(join("", [var.customVmName, "Nic"]))
  publicIPAddressType = "Dynamic"
  osDiskName          = lower(join("", [var.customVmName, "_OsDisk"]))
  addressPrefix       = "10.0.0.0/16"
  subnetPrefix        = "10.0.0.0/24"
  storageAccountName  = lower(join("", ["diag", "${random_string.asaname-01.result}"]))
}

# Generate random string for OS disk
resource "random_string" "avmosd-01" {
  length  = 32
  special = "false"
}

# Random string for storage account name  
resource "random_string" "asaname-01" {
  length  = 16
  special = "false"
}

# Resource Group
resource "azurerm_resource_group" "arg-01" {
  count    = var.vnet-new-or-existing == "new" ? 1 : 0
  name     = var.resourceGroupName
  location = var.location
}

# Public IP for new resource group
resource "azurerm_public_ip" "apip-01" {
  count               = var.vnet-new-or-existing == "new" ? 1 : 0
  name                = local.publicIPAddressName
  resource_group_name = azurerm_resource_group.arg-01.*.name[count.index]
  location            = azurerm_resource_group.arg-01.*.location[count.index]
  allocation_method   = local.publicIPAddressType
  domain_name_label   = var.dnsLabelPrefix
}

# Public IP under existing resource group 
resource "azurerm_public_ip" "apip-exisiting-01" {
  count               = var.vnet-new-or-existing == "existing" ? 1 : 0
  name                = local.publicIPAddressName
  resource_group_name = data.azurerm_virtual_network.vnet-existing-01.*.resource_group_name[count.index]
  location            = data.azurerm_virtual_network.vnet-existing-01.*.location[count.index]
  allocation_method   = local.publicIPAddressType
  domain_name_label   = var.dnsLabelPrefix
}

# Storage account under new resource group
resource "azurerm_storage_account" "asa-01" {
  count                    = var.vnet-new-or-existing == "new" ? 1 : 0
  name                     = local.storageAccountName
  resource_group_name      = azurerm_resource_group.arg-01.*.name[count.index]
  location                 = azurerm_resource_group.arg-01.*.location[count.index]
  account_replication_type = "LRS"
  account_tier             = "Standard"
}

# Storage account under existing resource group
resource "azurerm_storage_account" "asa-existing-01" {
  count                    = var.vnet-new-or-existing == "existing" ? 1 : 0
  name                     = local.storageAccountName
  resource_group_name      = data.azurerm_virtual_network.vnet-existing-01.*.resource_group_name[count.index]
  location                 = data.azurerm_virtual_network.vnet-existing-01.*.location[count.index]
  account_replication_type = "LRS"
  account_tier             = "Standard"
}

# Creating new Virtual Network
resource "azurerm_virtual_network" "avn-01" {
  count               = var.vnet-new-or-existing == "new" ? 1 : 0
  name                = var.newVnetName
  resource_group_name = azurerm_resource_group.arg-01.*.name[count.index]
  location            = azurerm_resource_group.arg-01.*.location[count.index]
  address_space       = [local.addressPrefix]
}

# Creating subnet under new virtual network
resource "azurerm_subnet" "as-01" {
  count                = var.vnet-new-or-existing == "new" ? 1 : 0
  name                 = var.newsubnetName
  resource_group_name  = azurerm_resource_group.arg-01.*.name[count.index]
  virtual_network_name = azurerm_virtual_network.avn-01.*.name[count.index]
  address_prefixes     = [local.subnetPrefix]
}

# Network interface with IP configuration
resource "azurerm_network_interface" "anic-01" {
  count               = var.vnet-new-or-existing == "new" ? 1 : 0
  name                = local.nicName
  resource_group_name = azurerm_resource_group.arg-01.*.name[count.index]
  location            = azurerm_resource_group.arg-01.*.location[count.index]
  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.apip-01.*.id[count.index]
    subnet_id                     = azurerm_subnet.as-01.*.id[count.index]
  }
}

# Network interface with IP configuration under existing resource group
resource "azurerm_network_interface" "anic-existing-01" {
  count               = var.vnet-new-or-existing == "existing" ? 1 : 0
  name                = local.nicName
  resource_group_name = data.azurerm_virtual_network.vnet-existing-01.*.resource_group_name[count.index]
  location            = data.azurerm_virtual_network.vnet-existing-01.*.location[count.index]
  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.apip-exisiting-01.*.id[count.index]
    subnet_id                     = data.azurerm_subnet.asn-existing-01.*.id[count.index]
  }
}

# Vhd image 
resource "azurerm_image" "aimg-01" {
  count               = var.vnet-new-or-existing == "new" ? 1 : 0
  name                = local.imageName
  resource_group_name = azurerm_resource_group.arg-01.*.name[count.index]
  location            = azurerm_resource_group.arg-01.*.location[count.index]
  os_disk {
    os_type  = var.osType[0]
    os_state = "Generalized"
    blob_uri = var.osDiskVhdUri
  }
  data_disk {
    lun      = 1
    blob_uri = var.dataDiskVhdUri
  }
}

# Vhd image under existing resource group
resource "azurerm_image" "aimg-existing-01" {
  count               = var.vnet-new-or-existing == "existing" ? 1 : 0
  name                = local.imageName
  resource_group_name = data.azurerm_virtual_network.vnet-existing-01.*.resource_group_name[count.index]
  location            = data.azurerm_virtual_network.vnet-existing-01.*.location[count.index]
  os_disk {
    os_type  = var.osType[0]
    os_state = "Generalized"
    blob_uri = var.osDiskVhdUri
  }
  data_disk {
    lun      = 1
    blob_uri = var.dataDiskVhdUri
  }
}

# Virtual Machine under new resource group
resource "azurerm_virtual_machine" "avm-01" {
  count                 = var.vnet-new-or-existing == "new" ? 1 : 0
  name                  = var.customVmName
  resource_group_name   = azurerm_resource_group.arg-01.*.name[count.index]
  location              = azurerm_resource_group.arg-01.*.location[count.index]
  vm_size               = var.vmSize
  network_interface_ids = [azurerm_network_interface.anic-01.*.id[count.index]]
  os_profile {
    computer_name  = var.customVmName
    admin_username = var.adminUsername
    admin_password = var.adminPassword
  }
  storage_os_disk {
    name          = local.osDiskName
    create_option = "FromImage"
  }
  storage_image_reference {
    id = azurerm_image.aimg-01.*.id[count.index]
  }
  os_profile_windows_config {
    provision_vm_agent = "true"
  }
  boot_diagnostics {
    storage_uri = azurerm_storage_account.asa-01.*.primary_blob_endpoint[count.index]
    enabled     = "true"
  }
}

# Using existing virtual network 
data "azurerm_virtual_network" "vnet-existing-01" {
  count               = var.vnet-new-or-existing == "existing" ? 1 : 0
  name                = var.existingVnetName
  resource_group_name = "test-rg"
}

# Using existing subnet
data "azurerm_subnet" "asn-existing-01" {
  count                = var.vnet-new-or-existing == "existing" ? 1 : 0
  name                 = var.existingsubnetName
  virtual_network_name = "exisiting-vnet"
  resource_group_name  = "test-rg"
}

# Provisioning virtual Machine under existing resource group
resource "azurerm_virtual_machine" "avm-existing-01" {
  count                            = var.vnet-new-or-existing == "existing" ? 1 : 0
  name                             = var.customVmName
  resource_group_name              = data.azurerm_virtual_network.vnet-existing-01.*.resource_group_name[count.index]
  location                         = data.azurerm_virtual_network.vnet-existing-01.*.location[count.index]
  vm_size                          = var.vmSize
  network_interface_ids            = [azurerm_network_interface.anic-existing-01.*.id[count.index]]
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true
  os_profile {
    computer_name  = var.customVmName
    admin_username = var.adminUsername
    admin_password = var.adminPassword
  }
  storage_os_disk {
    name          = local.osDiskName
    create_option = "FromImage"
  }
  storage_image_reference {
    id = azurerm_image.aimg-existing-01.*.id[count.index]
  }
  os_profile_windows_config {
    provision_vm_agent = "true"
  }
  boot_diagnostics {
    storage_uri = azurerm_storage_account.asa-existing-01.*.primary_blob_endpoint[count.index]
    enabled     = "true"
  }
}
