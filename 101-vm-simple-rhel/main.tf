# Defining the local variables
locals {
  dataDisk1Name            = join("", [random_string.disk1.result, var.vmName, "datadisk1"])
  dataDisk2Name            = join("", [random_string.disk2.result, var.vmName, "datadisk2"])
  imagePublisher           = "RedHat"
  imageOffer               = "RHEL"
  imageSku                 = "7.2"
  nicName                  = join("", [var.vmName, "nic"])
  addressPrefix            = "10.0.0.0/16"
  subnetName               = "Subnet"
  subnetPrefix             = "10.0.0.0/24"
  publicIPAddressName      = join("", [var.vmName, "publicip"])
  publicIPAddressType      = "Dynamic"
  vmSize                   = "Standard_A2"
  virtualNetworkName       = join("", [var.vmName, "vnet"])
  networkSecurityGroupName = "default-NSG"

  ssh_key = {
    username   = var.adminUsername
    public_key = file("~/.ssh/id_rsa.pub")
  }
}

# Generate random string for datadisk1
resource "random_string" "disk1" {
  length  = 8
  special = "false"
}

# Generate random string for datadisk2
resource "random_string" "disk2" {
  length  = 8
  special = "false"
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

# Create VM if authentication type is SSH
resource "azurerm_linux_virtual_machine" "avm-ssh-01" {
  name                  = var.vmName
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
    sku       = local.imageSku
    version   = "latest"
  }
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
  tags = {
    Tag1 = "ManagedVM"
  }
}

# Managed disk
resource "azurerm_managed_disk" "amd-01" {
  name                 = local.dataDisk1Name
  resource_group_name  = azurerm_resource_group.arg-01.name
  location             = azurerm_resource_group.arg-01.location
  create_option        = "Empty"
  storage_account_type = "Standard_LRS"
  disk_size_gb         = 100
}

resource "azurerm_managed_disk" "amd-02" {
  name                 = local.dataDisk2Name
  resource_group_name  = azurerm_resource_group.arg-01.name
  location             = azurerm_resource_group.arg-01.location
  create_option        = "Empty"
  storage_account_type = "Standard_LRS"
  disk_size_gb         = 100
}

# Attaching managed disk 1 to virtual machine
resource "azurerm_virtual_machine_data_disk_attachment" "adattach-01" {
  managed_disk_id    = azurerm_managed_disk.amd-01.id
  virtual_machine_id = azurerm_linux_virtual_machine.avm-ssh-01.id
  caching            = "ReadWrite"
  lun                = 0
}

# Attaching managed disk 2 to virtual machine
resource "azurerm_virtual_machine_data_disk_attachment" "adattach-02" {
  managed_disk_id    = azurerm_managed_disk.amd-02.id
  virtual_machine_id = azurerm_linux_virtual_machine.avm-ssh-01.id
  caching            = "ReadWrite"
  lun                = 1
}
