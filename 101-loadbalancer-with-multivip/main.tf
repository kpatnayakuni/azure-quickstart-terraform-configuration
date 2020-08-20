# Defining the local variables
locals {
    virtualNetworkName = "virtualNetwork1"
    publicIPAddressName1 = "publicIp1"
    publicIPAddressName2 = "publicIp2"
    subnetName = "subnet1"
    loadBalancerName = "loadBalancer1"
    nicName = "networkInterface1"
}

# Resource Group
resource "azurerm_resource_group" "arg-01" {
  name     = var.resourceGroupName
  location = var.location
}

# public IP
resource "azurerm_public_ip" "apip-01" {
  name = local.publicIPAddressName1
  location = azurerm_resource_group.arg-01.location
  resource_group_name = azurerm_resource_group.arg-01.name
  allocation_method = var.publicIPAddressType[0]
  domain_name_label   = var.dnsNameforLBIP
}

resource "azurerm_public_ip" "apip-02" {
  name = local.publicIPAddressName2
  location = azurerm_resource_group.arg-01.location
  resource_group_name = azurerm_resource_group.arg-01.name
  allocation_method = var.publicIPAddressType[0]
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
  name = local.subnetName
  resource_group_name = azurerm_resource_group.arg-01.name
  virtual_network_name = azurerm_virtual_network.avn-01.name
  address_prefixes = [var.subnetprefix]
}

# Network interface
resource "azurerm_network_interface" "ani-01" {
  name = local.nicName
  location = azurerm_resource_group.arg-01.location
  resource_group_name = azurerm_resource_group.arg-01.name
  ip_configuration {
    name = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    subnet_id = azurerm_subnet.as-01.id
  }
}

# Associate network Interface and backend address pool
resource "azurerm_network_interface_backend_address_pool_association" "assbp-01" {
  network_interface_id = azurerm_network_interface.ani-01.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.abp-01.id
}

#Load Balancer with 2 frontend ipconfigurations 
 resource "azurerm_lb" "alb-01" {
  name = local.loadBalancerName
  location = azurerm_resource_group.arg-01.location
  resource_group_name = azurerm_resource_group.arg-01.name
  frontend_ip_configuration {
    name = "loadBalancerFrontEnd1"
    public_ip_address_id = azurerm_public_ip.apip-01.id
  }
  frontend_ip_configuration {
    name = "loadBalancerFrontEnd2"
    public_ip_address_id = azurerm_public_ip.apip-02.id
  }
}

# Backend address pool
resource "azurerm_lb_backend_address_pool" "abp-01" {
  name = "loadBalancerBackEnd"
  resource_group_name = azurerm_resource_group.arg-01.name
  loadbalancer_id = azurerm_lb.alb-01.id
}

# Loadbalancing rule
resource "azurerm_lb_rule" "albrule-01" {
  name = "LBRuleForVIP1"
  resource_group_name = azurerm_resource_group.arg-01.name
  backend_address_pool_id = azurerm_lb_backend_address_pool.abp-01.id
  loadbalancer_id = azurerm_lb.alb-01.id
  protocol = "tcp"
  frontend_port = 443
  backend_port = 443
  probe_id = azurerm_lb_probe.apb-01.id
  frontend_ip_configuration_name = "loadBalancerFrontEnd1"
}

resource "azurerm_lb_rule" "albrule-02" {
  name = "LBRuleForVIP2"
  resource_group_name = azurerm_resource_group.arg-01.name
  backend_address_pool_id = azurerm_lb_backend_address_pool.abp-01.id
  loadbalancer_id = azurerm_lb.alb-01.id
  protocol = "tcp"
  frontend_port = 443
  backend_port = 444
  probe_id = azurerm_lb_probe.apb-01.id
  frontend_ip_configuration_name = "loadBalancerFrontEnd2"
}

# Probe
resource "azurerm_lb_probe" "apb-01" {
  name = "tcpProbe"
  resource_group_name = azurerm_resource_group.arg-01.name
  port = 445
  protocol = "tcp"
  interval_in_seconds = 5
  number_of_probes = 2
  loadbalancer_id = azurerm_lb.alb-01.id
}