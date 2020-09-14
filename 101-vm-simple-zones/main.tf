
# Defining the local variables
locals {
  publicIpAddressName  = join("", [var.vmName, "PublicIP"])
  networkInterfaceName = join("", [var.vmName, "NetInt"])
  osDiskType           = "Standard_LRS"
  subnetAddressPrefix  = "10.1.0.0/24"
  addressPrefix        = "10.1.0.0/16"
  dnsLabelPrefix       = lower(join("", ["linuxvm-", random_string.vmd.result]))

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

# Resource Group
resource "azurerm_resource_group" "arg-01" {
  name     = var.resourceGroupName
  location = var.location
}

# Network security group with SSH allow rule
resource "azurerm_network_security_group" "ansg-01" {
  name                = var.networkSecurityGroupName
  resource_group_name = azurerm_resource_group.arg-01.name
  location            = azurerm_resource_group.arg-01.location
  security_rule {
    name                       = "SSH"
    priority                   = 1000
    protocol                   = "TCP"
    access                     = "Allow"
    direction                  = "Inbound"
    destination_port_range     = "22"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "avn-01" {
  name                = var.virtualNetworkName
  resource_group_name = azurerm_resource_group.arg-01.name
  location            = azurerm_resource_group.arg-01.location
  address_space       = [local.addressPrefix]
}

# Subnet
resource "azurerm_subnet" "as-01" {
  name                                           = var.subnetName
  resource_group_name                            = azurerm_resource_group.arg-01.name
  virtual_network_name                           = azurerm_virtual_network.avn-01.name
  address_prefixes                               = [local.subnetAddressPrefix]
  enforce_private_link_endpoint_network_policies = true
  enforce_private_link_service_network_policies  = true
}

# Associate subnet and Network interface
resource "azurerm_network_interface_security_group_association" "asnsga-0" {
  network_interface_id      = azurerm_network_interface.anic-01.id
  network_security_group_id = azurerm_network_security_group.ansg-01.id
}

# Public IP
resource "azurerm_public_ip" "apip-01" {
  name                    = local.publicIpAddressName
  resource_group_name     = azurerm_resource_group.arg-01.name
  location                = azurerm_resource_group.arg-01.location
  allocation_method       = "Static"
  ip_version              = "IPv4"
  idle_timeout_in_minutes = "4"
  sku                     = "Standard"
  domain_name_label       = local.dnsLabelPrefix
  zones                   = [var.zone]
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

# Create VM if authentication type is SSH or password
resource "azurerm_linux_virtual_machine" "avm-01" {
  name                  = var.vmName
  resource_group_name   = azurerm_resource_group.arg-01.name
  location              = azurerm_resource_group.arg-01.location
  network_interface_ids = [azurerm_network_interface.anic-01.id]
  size                  = var.VmSize
  zone                  = var.zone
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = local.osDiskType
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = var.ubuntuOSVersion
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
}

## Output
# Username 
output "adminUsername" {
  value = var.adminUsername
}

# Host FQDN 
output "hostname" {
  value = azurerm_public_ip.apip-01.fqdn
}

# SSH Command
output "sshCommand" {
  value = "${var.adminUsername}@${azurerm_public_ip.apip-01.fqdn}"
}
