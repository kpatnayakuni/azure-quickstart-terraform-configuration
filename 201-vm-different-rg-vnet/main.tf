# Defining the local variables
locals {
  ssh_key = {
    username   = var.adminUsername
    public_key = file("~/.ssh/id_rsa.pub")
  }
}

# Resource Group
resource "azurerm_resource_group" "arg-01" {
  name     = var.resourceGroupName
  location = var.location
}

# Storage account
resource "azurerm_storage_account" "asa-01" {
  name                     = var.newStorageAccountName
  resource_group_name      = azurerm_resource_group.arg-01.name
  location                 = azurerm_resource_group.arg-01.location
  account_kind             = "storagev2"
  account_tier             = var.tier
  account_replication_type = var.replicationtype
}

# Public IP
resource "azurerm_public_ip" "apip-01" {
  name                = var.publicIPName
  resource_group_name = azurerm_resource_group.arg-01.name
  location            = azurerm_resource_group.arg-01.location
  allocation_method   = var.publicIPAddressType
}

# Network interface with IP configuration
resource "azurerm_network_interface" "anic-01" {
  name                = var.nicName
  resource_group_name = azurerm_resource_group.arg-01.name
  location            = azurerm_resource_group.arg-01.location
  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.apip-01.id
    subnet_id                     = data.azurerm_subnet.as-01.id
  }
}

# Using existing resource group
data "azurerm_resource_group" "arg-ex-01" {
  name = var.virtualNetworkResourceGroup
}

# Using existing virtual network
data "azurerm_virtual_network" "avnet-01" {
  name                = var.virtualNetworkName
  resource_group_name = var.virtualNetworkResourceGroup
}

# Using existing subnet
data "azurerm_subnet" "as-01" {
  name                 = var.subnet1Name
  virtual_network_name = data.azurerm_virtual_network.avnet-01.name
  resource_group_name  = var.virtualNetworkResourceGroup
}

# Create VM if authentication type is SSH
resource "azurerm_linux_virtual_machine" "avm-ssh-01" {
  name                  = var.vmName
  resource_group_name   = azurerm_resource_group.arg-01.name
  location              = azurerm_resource_group.arg-01.location
  size                  = var.vmSize
  network_interface_ids = [azurerm_network_interface.anic-01.id]
  os_disk {
    name                 = join("", [var.vmName, "_OSDisk"])
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = var.imagePublisher
    offer     = var.imageOffer
    sku       = var.imageSKU
    version   = "latest"
  }
  admin_username                  = var.adminUsername
  admin_password                  = var.authenticationType == "sshPublicKey" ? null : var.adminPassword
  disable_password_authentication = var.authenticationType == "sshPublicKey" ? true : false
  dynamic "admin_ssh_key" {
    for_each = var.authenticationType == "sshPublicKey" ? [local.ssh_key] : []
    content {
      username   = admin_ssh_key.value["username"]
      public_key = admin_ssh_key.value["public_key"]
    }
  }
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.asa-01.primary_blob_endpoint
  }
}
