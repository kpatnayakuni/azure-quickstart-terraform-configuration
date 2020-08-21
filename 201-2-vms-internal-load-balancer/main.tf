# Defining the local variables
locals {
  availabilitySetName       = "AVSet"
  storageAccountType        = "Standard"
  virtualNetworkName        = "vNet"
  subnetname                = "backendSubnet"
  loadBalancerName          = "ilb"
  networkSecurityGroupName  = "nsg"
  storageAccountName        = lower(join("", ["diag", "${random_string.asaname-01.result}"]))
  osDiskName                = join("",["${var.vmnameprefix}", "_OsDisk_1_", lower("${random_string.avmosd-01.result}")])
}

# Resource Group
resource "azurerm_resource_group" "arg-01" {
  name      = var.resource_group_name
  location  = var.location
}

# Random string for storage account name  
resource "random_string" "asaname-01" {
  length  = 16
  special = "false"
}

# Storage account
resource "azurerm_storage_account" "asa-01" {
  name                      = local.storageAccountName
  resource_group_name       = azurerm_resource_group.arg-01.name
  location                  = azurerm_resource_group.arg-01.location
  account_tier              = local.storageAccountType
  account_replication_type  = "LRS"
}

# Avaliability set
resource "azurerm_availability_set" "avset" {
  name                         = local.availabilitySetName
  location                     = azurerm_resource_group.arg-01.location
  resource_group_name          = azurerm_resource_group.arg-01.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

# Virtual Network
resource "azurerm_virtual_network" "avn-01" {
  name                = local.virtualNetworkName
  location            = azurerm_resource_group.arg-01.location
  resource_group_name = azurerm_resource_group.arg-01.name
  address_space       = ["10.0.0.0/16"]
}

# Subnet
resource "azurerm_subnet" "as-01" {
  name                  = local.subnetname
  resource_group_name   = azurerm_resource_group.arg-01.name
  virtual_network_name  = azurerm_virtual_network.avn-01.name
  address_prefixes      = ["10.0.2.0/24"]
}

#Load Balancer
resource "azurerm_lb" "alb-01" {
  name                = local.loadBalancerName
  location            = azurerm_resource_group.arg-01.location
  resource_group_name = azurerm_resource_group.arg-01.name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                          = "LoadBalancerFrontEnd"
    subnet_id                     = azurerm_subnet.as-01.id
    private_ip_address            = "10.0.2.6"
    private_ip_address_allocation = "Static"
  }
}

# Backend address pool
resource "azurerm_lb_backend_address_pool" "abp-01" {
  name                = "BackendPool1"
  resource_group_name = azurerm_resource_group.arg-01.name
  loadbalancer_id     = azurerm_lb.alb-01.id
}

# Associate network Interface and backend address pool
resource "azurerm_network_interface_backend_address_pool_association" "assbp-01" {
  count                   = 2
  network_interface_id    = element(azurerm_network_interface.ani-01.*.id,count.index)
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.abp-01.id
}

# Probe
resource "azurerm_lb_probe" "albp-01" {
  name                = "lbprobe"
  resource_group_name = azurerm_resource_group.arg-01.name
  port                = 80
  protocol            = "tcp"
  interval_in_seconds = 15
  number_of_probes    = 2
  loadbalancer_id     = azurerm_lb.alb-01.id
}

# Loadbalancing rule
resource "azurerm_lb_rule" "albrule-01" {
  name                            = "lbrule"
  resource_group_name             = azurerm_resource_group.arg-01.name
  backend_address_pool_id         = azurerm_lb_backend_address_pool.abp-01.id 
  probe_id                        = azurerm_lb_probe.albp-01.id
  protocol                        = "tcp"
  backend_port                    = 80
  frontend_port                   = 80
  idle_timeout_in_minutes         = 15
  frontend_ip_configuration_name  = "LoadBalancerFrontEnd"
  loadbalancer_id                 = azurerm_lb.alb-01.id
}

# Network interface
resource "azurerm_network_interface" "ani-01" {
  count               = 2
  name                = "${var.networkInterfaceName}${count.index}"
  location            = azurerm_resource_group.arg-01.location
  resource_group_name = azurerm_resource_group.arg-01.name
  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.as-01.id
  }
}

# Random string for OS disk
resource "random_string" "avmosd-01" {
  length  = 32
  special = "false"
}

# Virtual Machine
resource "azurerm_virtual_machine" "avm01" {
  count                             = 2
  name                              = "${var.vmnameprefix}${count.index}"
  vm_size                           = "Standard_DS2_V2"
  resource_group_name               = azurerm_resource_group.arg-01.name
  location                          = azurerm_resource_group.arg-01.location
  availability_set_id               = azurerm_availability_set.avset.id
  network_interface_ids             = [element(azurerm_network_interface.ani-01.*.id, count.index)]
  delete_os_disk_on_termination     = true
  delete_data_disks_on_termination  = true
  os_profile {
    computer_name  = "${var.vmnameprefix}${count.index}"
    admin_username = var.adminUsername
    admin_password = var.adminPassword
 }
 storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
 }
 os_profile_windows_config {
    provision_vm_agent = "true"
 }
  storage_os_disk {
    name          = "${local.osDiskName}${count.index}"
    create_option = "FromImage"
  }
  boot_diagnostics {
    storage_uri = azurerm_storage_account.asa-01.primary_blob_endpoint
    enabled     = "true"
  }
}
 