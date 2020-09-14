# Defining the local variables
locals {
  storageAccountName       = join("", ["diags", random_string.srg.result])
  imageName                = join("", [var.osType, "-image"])
  nicName                  = "myVMNic"
  addressPrefix            = "10.0.0.0/16"
  subnetName               = "Subnet"
  subnetPrefix             = "10.0.0.0/24"
  publicIPAddressName      = "myPublicIP"
  virtualNetworkName       = "MyVNET"
  networkSecurityGroupName = "nsgAllowRemoting"
  osDiskName               = join("", [var.vmName, "_OsDisk"])
  dnsLabelPrefix           = join("", ["vm", random_string.vmd.result])
  ssh_key = {
    username   = var.adminUsername
    public_key = file("~/.ssh/id_rsa.pub")
  }
}

# Generate random string for DNS Prefix
resource "random_string" "vmd" {
  length  = 16
  special = "false"
}

# Generate random string for storage Prefix
resource "random_string" "srg" {
  length  = 16
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

resource "azurerm_storage_account" "asa-01" {
  name                     = local.storageAccountName
  resource_group_name      = azurerm_resource_group.arg-01.name
  location                 = azurerm_resource_group.arg-01.location
  account_kind             = "storage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Vhd image 
resource "azurerm_image" "aimg-01" {
  name                = local.imageName
  resource_group_name = azurerm_resource_group.arg-01.name
  location            = azurerm_resource_group.arg-01.location
  os_disk {
    os_type  = var.osType
    os_state = "Generalized"
    blob_uri = var.osDiskVhdUri
  }
  hyper_v_generation = "V2"

}

# Public IP 
resource "azurerm_public_ip" "apip-01" {
  name                = local.publicIPAddressName
  resource_group_name = azurerm_resource_group.arg-01.name
  location            = azurerm_resource_group.arg-01.location
  allocation_method   = "Static"
  sku                 = "standard"
  domain_name_label   = local.dnsLabelPrefix
}

# Network security group
resource "azurerm_network_security_group" "ansg-01" {
  name                = local.networkSecurityGroupName
  resource_group_name = azurerm_resource_group.arg-01.name
  location            = azurerm_resource_group.arg-01.location
}

resource "azurerm_network_security_rule" "sshrule-01" {
  count                       = var.osType == "ssh" ? 1 : 0
  description                 = "Allow RDP/SSH"
  name                        = "RemoteConnection"
  priority                    = 100
  protocol                    = "Tcp"
  access                      = "Allow"
  direction                   = "Inbound"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "22"
  resource_group_name         = azurerm_resource_group.arg-01.name
  network_security_group_name = azurerm_network_security_group.ansg-01.name
}

resource "azurerm_network_security_rule" "winrule-01" {
  count                       = var.osType == "windows" ? 1 : 0
  description                 = "Allow RDP/SSH"
  name                        = "RemoteConnection"
  priority                    = 100
  protocol                    = "Tcp"
  access                      = "Allow"
  direction                   = "Inbound"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "3389"
  resource_group_name         = azurerm_resource_group.arg-01.name
  network_security_group_name = azurerm_network_security_group.ansg-01.name
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

# Associate subnet and Network interface
resource "azurerm_network_interface_security_group_association" "asnsga-0" {
  network_interface_id      = azurerm_network_interface.anic-01.id
  network_security_group_id = azurerm_network_security_group.ansg-01.id
}

# Virtual Machine under new resource group
resource "azurerm_linux_virtual_machine" "avm-lin-01" {
  count                 = var.osType == "Windows" ? 0 : 1
  name                  = var.vmName
  resource_group_name   = azurerm_resource_group.arg-01.name
  location              = azurerm_resource_group.arg-01.location
  network_interface_ids = [azurerm_network_interface.anic-01.id]
  size                  = var.vmSize
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_id = azurerm_image.aimg-01.id
  admin_username                  = var.adminUsername
  admin_password                  = var.authenticationType == "sshPublicKey" ? null : var.adminPasswordOrKey
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

resource "azurerm_windows_virtual_machine" "avm-win-01" {
  count                 = var.osType == "Windows" ? 1 : 0
  name                  = var.vmName
  resource_group_name   = azurerm_resource_group.arg-01.name
  location              = azurerm_resource_group.arg-01.location
  network_interface_ids = [azurerm_network_interface.anic-01.id]
  size                  = var.vmSize
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_id = azurerm_image.aimg-01.id
  
  admin_username = var.adminUsername
  admin_password = var.adminPasswordOrKey

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.asa-01.primary_blob_endpoint
  }
}

# Host FQDN 
output "hostname" {
  value = azurerm_public_ip.apip-01.fqdn
}