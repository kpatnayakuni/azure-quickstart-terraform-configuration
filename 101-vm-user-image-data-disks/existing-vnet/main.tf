# Defining the local variables
locals {
  publicIPAddressName = lower(join("", [var.customVmName, "IP"]))
  nicName             = lower(join("", [var.customVmName, "Nic"]))
  osDiskName          = lower(join("", [var.customVmName, "_OsDisk"]))
}

# Fetch details of resource group where shared resources exists
data "azurerm_resource_group" "arg-01" {
  name = var.resourceGroupName
}

# Fetch details of storage account
data "azurerm_storage_account" "asa-01" {
  name                = var.bootDiagnosticsStorageAccountName
  resource_group_name = var.bootDiagnosticsStorageAccountResourceGroupName
}

# Fetch existing virtual network
data "azurerm_virtual_network" "vnet-existing-01" {
  name                = var.existingVnetName
  resource_group_name = var.resourceGroupName
}

# Fetch existing subnet 
data "azurerm_subnet" "asn-existing-01" {
  name                 = var.existingsubnetName
  virtual_network_name = "exisiting-vnet"
  resource_group_name  = var.resourceGroupName
}

# Generate random string for OS disk
resource "random_string" "avmosd-01" {
  length  = 32
  special = "false"
}

# Public IP under existing resource group 
resource "azurerm_public_ip" "apip-exisiting-01" {
  name                = local.publicIPAddressName
  resource_group_name = data.azurerm_resource_group.arg-01.name
  location            = data.azurerm_resource_group.arg-01.location
  allocation_method   = var.publicIPAddressType
  domain_name_label   = var.dnsLabelPrefix
}

# Network interface with IP configuration under existing resource group
resource "azurerm_network_interface" "anic-existing-01" {
  name                = local.nicName
  resource_group_name = data.azurerm_resource_group.arg-01.name
  location            = data.azurerm_resource_group.arg-01.location
  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.apip-exisiting-01.id
    subnet_id                     = data.azurerm_subnet.asn-existing-01.id
  }
}

# Vhd image under existing resource group
resource "azurerm_image" "aimg-existing-01" {
  name                = var.imageName
  resource_group_name = data.azurerm_resource_group.arg-01.name
  location            = data.azurerm_resource_group.arg-01.location
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

# Provisioning virtual Machine under existing resource group
resource "azurerm_virtual_machine" "avm-existing-01" {
  name                             = var.customVmName
  resource_group_name              = data.azurerm_resource_group.arg-01.name
  location                         = data.azurerm_resource_group.arg-01.location
  vm_size                          = var.vmSize
  network_interface_ids            = [azurerm_network_interface.anic-existing-01.id]
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
    id = azurerm_image.aimg-existing-01.id
  }
  os_profile_windows_config {
    provision_vm_agent = "true"
  }
  boot_diagnostics {
    storage_uri = data.azurerm_storage_account.asa-01.primary_blob_endpoint
    enabled     = "true"
  }
}
