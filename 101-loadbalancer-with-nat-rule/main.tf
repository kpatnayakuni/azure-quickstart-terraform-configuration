# Defining the local variables
locals {
  virtualNetworkName = "virtualNetwork1"
  publicIPAddressName =  "publicIp1"
  subnetname = "subnet1"
  loadBalancerName = "loadBalancer1"
  nicName =  "networkInterface1"
  
}

# Resource Group
resource "azurerm_resource_group" "arg-01" {
  name      = var.resource_group_name
  location  = var.location
}



# Virtual Network
resource "azurerm_virtual_network" "avn-01" {
  name = local.virtualNetworkName
  location = azurerm_resource_group.arg-01.location
  resource_group_name = azurerm_resource_group.arg-01.name
  address_space = [var.addressPrefix]
}

# Subnet
resource "azurerm_subnet" "as-01" {
  name                = local.subnetname
  resource_group_name = azurerm_resource_group.arg-01.name
  virtual_network_name = azurerm_virtual_network.avn-01.name
  address_prefixes = [var.subnetPrefix]
}

# Network interface
resource "azurerm_network_interface" "ani-01" {
 
  name = var.networkInterfaceName
  location = azurerm_resource_group.arg-01.location
  resource_group_name = azurerm_resource_group.arg-01.name
  ip_configuration {
    name = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    subnet_id = azurerm_subnet.as-01.id
  }
}


# Public ip for load balancer
resource "azurerm_public_ip" "apip-01" {
  name                = local.publicIPAddressName
  location = azurerm_resource_group.arg-01.location
  resource_group_name = azurerm_resource_group.arg-01.name
  allocation_method   = var.publicIPAddressType
  domain_name_label = var.dnsNameforLBIP
}

#Load Balancer
resource "azurerm_lb" "alb-01" {
  name = local.loadBalancerName
  location = azurerm_resource_group.arg-01.location
  resource_group_name = azurerm_resource_group.arg-01.name
  sku = "basic"
  frontend_ip_configuration {
    name = "LoadBalancerFrontEnd"
    public_ip_address_id = azurerm_public_ip.apip-01.id
    
  }
}
# NAT rule
resource "azurerm_lb_nat_rule" "anrule-01" {
  resource_group_name            = azurerm_resource_group.arg-01.name
  loadbalancer_id                = azurerm_lb.alb-01.id
  name                           = "RDP"
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
}

# Associate network Interface and NAT rule
resource "azurerm_network_interface_nat_rule_association" "anna-01" {
  network_interface_id  = azurerm_network_interface.ani-01.id
  ip_configuration_name = "ipconfig1"
  nat_rule_id           = azurerm_lb_nat_rule.anrule-01.id
}

# Backend address pool
resource "azurerm_lb_backend_address_pool" "abp-01" {
  name = "loadbalencerbackend"
  resource_group_name = azurerm_resource_group.arg-01.name
  loadbalancer_id = azurerm_lb.alb-01.id
}

# Associate network Interface and backend address pool
resource "azurerm_network_interface_backend_address_pool_association" "assbp-01" {
  network_interface_id    = azurerm_network_interface.ani-01.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.abp-01.id
}





