# Defining the local variables
locals {
  storageAccountName       = lower(join("", ["sardpvm", random_string.asaname-01.result]))
  virtualNetworkName       = "rdpVNET"
  vnetAddressRange         = "10.6.0.0/16"
  subnetAddressRange       = "10.6.0.0/24"
  subnetName               = "Subnet"
  publicIPAddressName      = "myPublicIP"
  vmName                   = "SimpleWinVM"
  imagePublisher           = "MicrosoftWindowsServer"
  imageOffer               = "WindowsServer"
  imageSku                 = "2012-R2-Datacenter"
  networkSecurityGroupName = "Subnet-nsg"
  osDiskName               = join("", [local.vmName, "_OsDisk_1_"])
}

#Random string for Storage account
resource "random_string" "asaname-01" {
  length  = 16
  special = "false"
}

# Resource Group
resource "azurerm_resource_group" "arg-01" {
  name     = var.resourceGroupName
  location = var.location
}


# Public ip for load balancer
resource "azurerm_public_ip" "apip-01" {
  name                = "publicIp"
  resource_group_name = azurerm_resource_group.arg-01.name
  location            = azurerm_resource_group.arg-01.location
  allocation_method   = "Dynamic"
  domain_name_label   = var.dnsLabelPrefix
}

#Storage account for Boot diagnostics
resource "azurerm_storage_account" "asa-01" {
  name                     = local.storageAccountName
  resource_group_name      = azurerm_resource_group.arg-01.name
  location                 = azurerm_resource_group.arg-01.location
  account_replication_type = "LRS"
  account_tier             = "Standard"
}

# Security group for subnet 
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
  address_space       = [local.vnetAddressRange]
}

#Subnet
resource "azurerm_subnet" "as-01" {
  name                 = local.subnetName
  resource_group_name  = azurerm_resource_group.arg-01.name
  virtual_network_name = azurerm_virtual_network.avn-01.name
  address_prefixes     = [local.subnetAddressRange]
}

# Associate subnet and network security group 
resource "azurerm_subnet_network_security_group_association" "asnsga-01" {
  subnet_id                 = azurerm_subnet.as-01.id
  network_security_group_id = azurerm_network_security_group.ansg-01.id
}

resource "azurerm_lb" "alb-01" {
  name                = "loadBalancer"
  location            = azurerm_resource_group.arg-01.location
  resource_group_name = azurerm_resource_group.arg-01.name
  sku                 = "basic"
  frontend_ip_configuration {
    name                 = "LBFE"
    public_ip_address_id = azurerm_public_ip.apip-01.id

  }
}

# Backend address pool
resource "azurerm_lb_backend_address_pool" "abp-01" {
  name                = "LBBAP"
  resource_group_name = azurerm_resource_group.arg-01.name
  loadbalancer_id     = azurerm_lb.alb-01.id
}

# NAT rule
resource "azurerm_lb_nat_rule" "anrule-01" {
  resource_group_name            = azurerm_resource_group.arg-01.name
  loadbalancer_id                = azurerm_lb.alb-01.id
  name                           = "rdp1"
  protocol                       = "Tcp"
  frontend_port                  = var.rdpPort
  backend_port                   = 3389
  frontend_ip_configuration_name = "LBFE"
}

# Network interface
resource "azurerm_network_interface" "anic-01" {

  name                = "${var.vmName}-nic"
  location            = azurerm_resource_group.arg-01.location
  resource_group_name = azurerm_resource_group.arg-01.name
  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.as-01.id

  }
}

# Associate network Interface and NAT rule
resource "azurerm_network_interface_nat_rule_association" "anna-01" {
  network_interface_id  = azurerm_network_interface.anic-01.id
  ip_configuration_name = "ipconfig1"
  nat_rule_id           = azurerm_lb_nat_rule.anrule-01.id
}

# Associate network Interface and backend address pool
resource "azurerm_network_interface_backend_address_pool_association" "assbp-01" {
  network_interface_id    = azurerm_network_interface.anic-01.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.abp-01.id
}

# Virtual Machine
resource "azurerm_windows_virtual_machine" "avm-01" {
  name                  = local.vmName
  resource_group_name   = azurerm_resource_group.arg-01.name
  location              = azurerm_resource_group.arg-01.location
  size                  = "Standard_A0"
  admin_username        = var.adminUsername
  admin_password        = var.adminPassword
  network_interface_ids = [azurerm_network_interface.anic-01.id]

  source_image_reference {
    publisher = local.imagePublisher
    offer     = local.imageOffer
    sku       = local.imageSku
    version   = "latest"
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  boot_diagnostics {

    storage_account_uri = "https://${azurerm_storage_account.asa-01.name}.blob.core.windows.net/"
  }
}

output "Connectionstring" {

  value = "mstsc.exe /v:${azurerm_public_ip.apip-01.fqdn}:${var.rdpPort}"
}

