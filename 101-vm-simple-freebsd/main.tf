# Defining the local variables
locals {
  storageaccountname       = lower(join("", [random_string.sac.result, "safreebsdvm"]))
  imagePublisher           = "MicrosoftOSTC"
  imageOffer               = "FreeBSD"
  nicName                  = "myVMNic"
  addressPrefix            = "10.0.0.0/16"
  subnetName               = "Subnet"
  subnetPrefix             = "10.0.0.0/24"
  storageAccountType       = "Standard_LRS"
  publicIPAddressName      = "myPublicIP"
  publicIPAddressType      = "Dynamic"
  vmName                   = "MyFreeBSDVM"
  vmSize                   = "Standard_A1"
  virtualNetworkName       = "MyVNET"
  networkSecurityGroupName = lower(join("", [local.subnetName, "-nsg"]))

  ssh_key = {
    username   = var.adminUsername
    public_key = file("~/.ssh/id_rsa.pub")
  }
}

# Generate random string for Storage account
resource "random_string" "sac" {
  length  = 8
  special = "false"
}

# Resource Group
resource "azurerm_resource_group" "arg-01" {
  name     = var.resourceGroupName
  location = var.location
}

# Storage account
resource "azurerm_storage_account" "asa-01" {
  name                = local.storageaccountname
  resource_group_name = azurerm_resource_group.arg-01.name
  location            = azurerm_resource_group.arg-01.location
  # sku = local.storageAccountType
  account_replication_type = "LRS"
  account_tier             = "Standard"
  account_kind             = "storage"
}

# Public IP
resource "azurerm_public_ip" "apip-01" {
  name                = local.publicIPAddressName
  resource_group_name = azurerm_resource_group.arg-01.name
  location            = azurerm_resource_group.arg-01.location
  allocation_method   = local.publicIPAddressType
  domain_name_label   = var.dnsLabelPrefix
}

# Simple Network Security Group for subnet
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

# Create VM if authentication type is SSH
resource "azurerm_linux_virtual_machine" "avm-ssh-01" {
  name                  = local.vmName
  resource_group_name   = azurerm_resource_group.arg-01.name
  location              = azurerm_resource_group.arg-01.location
  size                  = local.vmSize
  network_interface_ids = [azurerm_network_interface.anic-01.id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = local.imagePublisher
    offer     = local.imageOffer
    sku       = var.freeBSDOSVersion[0]
    version   = "latest"
  }
  admin_username                  = var.adminUsername
  admin_password                  = var.authenticationType == "ssh" ? null : var.adminPasswordOrKey
  disable_password_authentication = var.authenticationType == "ssh" ? true : false
  dynamic "admin_ssh_key" {
    for_each = var.authenticationType == "ssh" ? [local.ssh_key] : []
    content {
      username   = admin_ssh_key.value["username"]
      public_key = admin_ssh_key.value["public_key"]
    }
  }
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.asa-01.primary_blob_endpoint
  }
}

# Output 
output "hostname" {
  value = azurerm_public_ip.apip-01.fqdn
}
output "sshCommand" {
  value = join("", [var.adminUsername, "@", azurerm_public_ip.apip-01.fqdn])
}

# Managed disk
resource "azurerm_managed_disk" "amd-01" {
  name                 = "datadisk"
  resource_group_name  = azurerm_resource_group.arg-01.name
  location             = azurerm_resource_group.arg-01.location
  create_option        = "Empty"
  disk_size_gb         = 1023
  storage_account_type = local.storageAccountType
}

# Attaching managed disk to virtual machine
resource "azurerm_virtual_machine_data_disk_attachment" "adattach-01" {
  managed_disk_id    = azurerm_managed_disk.amd-01.id
  virtual_machine_id = azurerm_linux_virtual_machine.avm-ssh-01.id
  caching            = "ReadWrite"
  lun                = 0
}
