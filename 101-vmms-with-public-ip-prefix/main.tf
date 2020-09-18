# Defining local variables
locals {
  addressPrefix       = "10.0.0.0/16"
  subnetPrefix        = "10.0.0.0/24"
  publicIPPrefixName  = join("", [var.vmssName, "pubipprefix"])
  dnsName             = lower(join("", ["dns", var.vmssName]))
  virtualNetworkName  = join("", [var.vmssName, "vnet"])
  publicIPAddressName = join("", [var.vmssName, "pip"])
  subnetName          = join("", [var.vmssName, "subnet"])
  loadBalancerName    = join("", [var.vmssName, "lb"])
  natPoolName         = join("", [var.vmssName, "natpool"])
  bePoolName          = join("", [var.vmssName, "bepool"])
  natStartPort        = 50000
  natEndPort          = 50120
  natBackendPort      = 22
  nicName             = join("", [var.vmssName, "nic"])
  ipConfigName        = join("", [var.vmssName, "ipconfig"])
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

resource "azurerm_public_ip_prefix" "apip-prefix-01" {
  name                = local.publicIPPrefixName
  location            = azurerm_resource_group.arg-01.location
  resource_group_name = azurerm_resource_group.arg-01.name
  sku                 = "Standard"
  prefix_length       = var.publicIPPrefixLength
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

# Public IP
resource "azurerm_public_ip" "apip-01" {
  name                = local.publicIPAddressName
  resource_group_name = azurerm_resource_group.arg-01.name
  location            = azurerm_resource_group.arg-01.location
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = local.dnsName
}

# Load Balancer with frontend ipconfiguration 
resource "azurerm_lb" "alb-01" {
  name                = local.loadBalancerName
  location            = azurerm_resource_group.arg-01.location
  resource_group_name = azurerm_resource_group.arg-01.name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = azurerm_public_ip.apip-01.id
  }
}

# Backend address pool
resource "azurerm_lb_backend_address_pool" "abp-01" {
  name                = local.bePoolName
  resource_group_name = azurerm_resource_group.arg-01.name
  loadbalancer_id     = azurerm_lb.alb-01.id
}

# Nat Pool
resource "azurerm_lb_nat_pool" "anat-01" {
  resource_group_name            = azurerm_resource_group.arg-01.name
  loadbalancer_id                = azurerm_lb.alb-01.id
  name                           = local.natPoolName
  protocol                       = "Tcp"
  frontend_port_start            = local.natStartPort
  frontend_port_end              = local.natEndPort
  backend_port                   = local.natBackendPort
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
}

# Virtual Machine scale set
resource "azurerm_linux_virtual_machine_scale_set" "avmss-01" {
  name                = var.vmssName
  location            = azurerm_resource_group.arg-01.location
  resource_group_name = azurerm_resource_group.arg-01.name
  sku                 = var.vmSku
  instances           = var.instanceCount
  upgrade_mode        = "Manual"
  overprovision       = false
  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadOnly"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
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
  network_interface {
    name    = local.nicName
    primary = true
    ip_configuration {
      name                                   = "ipConfigName"
      primary                                = true
      subnet_id                              = azurerm_subnet.as-01.id
      load_balancer_inbound_nat_rules_ids    = [azurerm_lb_nat_pool.anat-01.id]
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.abp-01.id]
      public_ip_address {
        name                    = "pub1"
        idle_timeout_in_minutes = 15
        public_ip_prefix_id     = azurerm_public_ip_prefix.apip-prefix-01.id
      }
    }
  }
}
