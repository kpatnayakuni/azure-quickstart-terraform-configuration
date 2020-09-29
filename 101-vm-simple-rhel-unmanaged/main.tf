# Defining the local variables
locals {
  storageAccountName            = lower(join("", [random_string.asa.result, "storage"]))
  dataDisk1VhdName              = lower(join("", [random_string.disks.result, var.vmName, "datadisk1"]))
  dataDisk2VhdName              = lower(join("", [random_string.disks.result, var.vmName, "datadisk2"]))
  imagePublisher                = "RedHat"
  imageOffer                    = "RHEL"
  OSDiskName                    = lower(join("", [random_string.disks.result, var.vmName, "osdisk"]))
  nicName                       = lower(join("", [var.vmName, "nic"]))
  addressPrefix                 = "10.0.0.0/16"
  subnetName                    = "Subnet"
  subnetPrefix                  = "10.0.0.0/24"
  storageAccountType            = "Standard"
  storageAccountreplicationType = "LRS"
  vmStorageAccountContainerName = "vhds"
  publicIPAddressName           = join("", [var.vmName, "publicip"])
  publicIPAddressType           = "Dynamic"
  vmSize                        = "Standard_DS2_v2"
  virtualNetworkName            = join("", [var.vmName, "vnet"])
  networkSecurityGroupName      = join("", [local.subnetName, "nsg"])
}

# Generate random string for storage account
resource "random_string" "asa" {
  length  = 8
  special = "false"
}

# Generate random string for datadisk2
resource "random_string" "disks" {
  length  = 8
  special = "false"
}

# Resource Group
resource "azurerm_resource_group" "arg-01" {
  name     = var.resourceGroupName
  location = var.location
}

#Storage account
resource "azurerm_storage_account" "asa-01" {
  name                     = local.storageAccountName
  resource_group_name      = azurerm_resource_group.arg-01.name
  location                 = azurerm_resource_group.arg-01.location
  account_replication_type = local.storageAccountreplicationType
  account_tier             = local.storageAccountType
}

# Storage Container for vhd
resource "azurerm_storage_container" "asac-01" {
  name                  = local.vmStorageAccountContainerName
  storage_account_name  = azurerm_storage_account.asa-01.name
  container_access_type = "private"
}

# Public IP
resource "azurerm_public_ip" "apip-01" {
  name                = local.publicIPAddressName
  resource_group_name = azurerm_resource_group.arg-01.name
  location            = azurerm_resource_group.arg-01.location
  allocation_method   = local.publicIPAddressType
}

# Network Security Group 
resource "azurerm_network_security_group" "ansg-01" {
  name                = local.networkSecurityGroupName
  resource_group_name = azurerm_resource_group.arg-01.name
  location            = azurerm_resource_group.arg-01.location
  security_rule {
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

# Create VM 
resource "azurerm_linux_virtual_machine" "avm-ssh-01" {
  name                  = var.vmName
  resource_group_name   = azurerm_resource_group.arg-01.name
  location              = azurerm_resource_group.arg-01.location
  vm_size               = local.vmSize
  network_interface_ids = [azurerm_network_interface.anic-01.id]

  storage_os_disk {
    name          = local.OSDiskName
    caching       = "ReadWrite"
    create_option = "FromImage"
    vhd_uri       = "${azurerm_storage_account.asa-01.primary_blob_endpoint}${azurerm_storage_container.asac-01.name}/${local.OSDiskName}.vhd"
  }
  storage_data_disk {
    name          = local.dataDisk1VhdName
    vhd_uri       = "${azurerm_storage_account.asa-01.primary_blob_endpoint}${azurerm_storage_container.asac-01.name}/${local.dataDisk1VhdName}.vhd"
    disk_size_gb  = "100"
    create_option = "Empty"
    lun           = 0
  }
  storage_data_disk {
    name          = local.dataDisk2VhdName
    vhd_uri       = "${azurerm_storage_account.asa-01.primary_blob_endpoint}${azurerm_storage_container.asac-01.name}/${local.dataDisk2VhdName}.vhd"
    disk_size_gb  = "100"
    create_option = "Empty"
    lun           = 1
  }
  storage_image_reference {
    publisher = local.imagePublisher
    offer     = local.imageOffer
    sku       = "7.2"
    version   = "latest"
  }
  os_profile {
    computer_name  = var.vmName
    admin_username = var.adminUsername
    admin_password = var.authenticationType == "sshPublicKey" ? null : var.adminPassword
  }
  os_profile_linux_config {
    disable_password_authentication = var.authenticationType == "sshPublicKey" ? true : false
    ssh_keys {
      path     = "/home/${var.adminUsername}/.ssh/authorized_keys"
      key_data = file("~/.ssh/id_rsa.pub")
    }
  }
  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.asa-01.primary_blob_endpoint
  }
}
