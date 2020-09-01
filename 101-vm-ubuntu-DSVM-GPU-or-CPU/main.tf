# Defining the local variables
locals {
  networkInterfaceName = lower(join("", ["var.vmName", "netint"]))
  virualmachinename    = var.vmName
  publicIPAddressName  = lower(join("", ["var.vmName", "publicIP"]))
  osDiskType           = "Standard_LRS"
  storageaccountname   = lower(join("", ["storage", random_string.sac.result]))
  vmsize = {
    CPU-4GB  = "Standard_B2s"
    CPU-7GB  = "Standard_DS2_v2"
    CPU-8GB  = "Standard_D2s_v3"
    CPU-14GB = "Standard_DS3_v2"
    CPU-16GB = "Standard_D4s_v3"
    GPU-56GB = "Standard_NC6_Promo"
  }
  ssh_key = {
    username   = var.admin_username
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

# Network security group with SSH allow rule
resource "azurerm_network_security_group" "ansg-01" {
  name                = var.networkSecurityGroupName
  resource_group_name = azurerm_resource_group.arg-01.name
  location            = azurerm_resource_group.arg-01.location
  security_rule {
    name                       = "JupyterHub"
    priority                   = 1010
    access                     = "Allow"
    direction                  = "Inbound"
    destination_port_range     = "8000"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "RStudioServer"
    priority                   = 1020
    access                     = "Allow"
    direction                  = "Inbound"
    destination_port_range     = "8787"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "SSH"
    priority                   = 1030
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
  name                = var.virtualNetworkName
  resource_group_name = azurerm_resource_group.arg-01.name
  location            = azurerm_resource_group.arg-01.location
  address_space       = ["10.0.0.0/24"]
}

# Subnet
resource "azurerm_subnet" "as-01" {
  name                                           = var.subnetName
  resource_group_name                            = azurerm_resource_group.arg-01.name
  virtual_network_name                           = azurerm_virtual_network.avn-01.name
  address_prefixes                               = ["10.0.0.0/24"]
  enforce_private_link_endpoint_network_policies = true
  enforce_private_link_service_network_policies  = true
}

# Associate subnet and network security group 
resource "azurerm_subnet_network_security_group_association" "asnsga-01" {
  subnet_id                 = azurerm_subnet.as-01.id
  network_security_group_id = azurerm_network_security_group.ansg-01.id
}

# Public IP
resource "azurerm_public_ip" "apip-01" {
  name                    = local.publicIPAddressName
  resource_group_name     = azurerm_resource_group.arg-01.name
  location                = azurerm_resource_group.arg-01.location
  allocation_method       = "Dynamic"
  ip_version              = "IPV4"
  idle_timeout_in_minutes = "4"
  sku                     = "Basic"
}

# Storage account
resource "azurerm_storage_account" "example" {
  name                     = local.storageaccountname
  resource_group_name      = azurerm_resource_group.arg-01.name
  location                 = azurerm_resource_group.arg-01.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "Storage"
}

# Create VM if authentication type is SSH
resource "azurerm_linux_virtual_machine" "avm-ssh-01" {
  name                  = var.vmName
  resource_group_name   = azurerm_resource_group.arg-01.name
  location              = azurerm_resource_group.arg-01.location
  size                  = lookup(local.vmsize, var.cpu-gpu)
  network_interface_ids = [azurerm_network_interface.anic-01.id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "microsoft-dsvm"
    offer     = "ubuntu-1804"
    sku       = "1804-gen2"
    version   = "latest"
  }
  admin_username                  = var.admin_username
  admin_password                  = var.authenticationType == "ssh" ? null : var.adminPassword
  disable_password_authentication = var.authenticationType == "ssh" ? true : false
  dynamic "admin_ssh_key" {
    for_each = var.authenticationType == "ssh" ? [local.ssh_key] : []
    content {
      username   = admin_ssh_key.value["username"]
      public_key = admin_ssh_key.value["public_key"]
    }
  }
}

# Output 
output "adminUsername" {
  value = var.admin_username
}
