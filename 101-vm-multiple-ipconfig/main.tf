# Defining the local variables
locals {
    addressPrefix = "10.0.0.0/16"
    subnetName = "mySubnet"
    subnetPrefix = "10.0.0.0/24"
    publicIPAddressType =  "Static"
    publicIPAddressType2 =  "Static"
    nicName =  "myNic1"
    vnetName =  "myVNet1"
    publicIPAddressName =  "myPublicIP"
    publicIPAddressName2 =  "myPublicIP2"
    vmName = "myVM1"
    vmSize = "Standard_DS3_v2"
    networkSecurityGroupName =  "default-NSG"
    osDiskName = join("",["${local.vmName}", "_OsDisk_1_"])
    provision_vm_agent = true
    disable_password_authentication = false
}

# Resource Group
resource "azurerm_resource_group" "arg-01" {
    name = var.resourceGroupName
    location = var.location
}

# Public IP 1
resource "azurerm_public_ip" "apip-01" {
    name = local.publicIPAddressName
    resource_group_name = azurerm_resource_group.arg-01.name
    location = azurerm_resource_group.arg-01.location
    allocation_method = local.publicIPAddressType
    domain_name_label = var.dnsLabelPrefix
}

# Public IP 2
resource "azurerm_public_ip" "apip-02" {
    name = local.publicIPAddressName2
    resource_group_name = azurerm_resource_group.arg-01.name
    location = azurerm_resource_group.arg-01.location
    allocation_method = local.publicIPAddressType2
    domain_name_label = var.dnsLabelPrefix1
}

# Network Security group
resource "azurerm_network_security_group" "ansg-01" {
    name = local.networkSecurityGroupName
    resource_group_name = azurerm_resource_group.arg-01.name
    location = azurerm_resource_group.arg-01.location
    security_rule {
        name = "default-allow-22"
        priority = 1000
        access = "Allow"
        direction = "Inbound"
        destination_port_range = 22
        protocol = "Tcp"
        source_port_range           = "*"
		source_address_prefix       = "*"
		destination_address_prefix  = "*"
    }
}

# Virtual Network
resource "azurerm_virtual_network" "avn-01" {
    name = local.vnetName
    resource_group_name = azurerm_resource_group.arg-01.name
    location = azurerm_resource_group.arg-01.location
    address_space = [local.addressPrefix]
    dns_servers = []
}

#Subnet
resource "azurerm_subnet" "as-01" {
    name = local.subnetName
    resource_group_name = azurerm_resource_group.arg-01.name
    virtual_network_name = azurerm_virtual_network.avn-01.name
    address_prefixes = [local.subnetPrefix]
}

# Associate subnet and network security group 
resource "azurerm_subnet_network_security_group_association" "asnsga-01" {
	subnet_id                   = azurerm_subnet.as-01.id
	network_security_group_id   = azurerm_network_security_group.ansg-01.id
}

# Network interface with IP configurations
resource "azurerm_network_interface" "ani-01" {
    name = local.nicName
    resource_group_name = azurerm_resource_group.arg-01.name
    location = azurerm_resource_group.arg-01.location
    ip_configuration {
        name = "IPConfig-1"
        primary = true
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.apip-01.id
        subnet_id = azurerm_subnet.as-01.id
    }
    ip_configuration {
        name = "IPConfig-2"
        private_ip_address = "10.0.0.5"
        private_ip_address_allocation = "Static"
        public_ip_address_id = azurerm_public_ip.apip-02.id
        subnet_id = azurerm_subnet.as-01.id
    }
    ip_configuration {
        name = "IPConfig-3"
        private_ip_address_allocation = "Dynamic"
        subnet_id = azurerm_subnet.as-01.id
    }
}

# Virtual Machine for Windows
resource "azurerm_virtual_machine" "avm-01" {
    count = lookup (var.imagePublisher,var.OSVersion) == "MicrosoftWindowsServer" ? 1 : 0
    name = local.vmName
    resource_group_name = azurerm_resource_group.arg-01.name
    location = azurerm_resource_group.arg-01.location
    vm_size = local.vmSize
    network_interface_ids = [azurerm_network_interface.ani-01.id]
    delete_os_disk_on_termination     = true
    delete_data_disks_on_termination  = true
    os_profile {
        computer_name = local.vmName
        admin_username = var.adminUsername
        admin_password = var.adminPassword
    }
    os_profile_windows_config {
        provision_vm_agent = "true"
    }                                 
    storage_image_reference {
        publisher = lookup (var.imagePublisher,var.OSVersion)
        offer = lookup (var.imageOffer,var.OSVersion)
        sku = var.OSVersion
        version = "latest"
    }
    storage_os_disk {
        name = local.osDiskName
        create_option = "FromImage"
    }
}

# Virtual Machine for Linux
resource "azurerm_virtual_machine" "avm-02" {
    count = lookup (var.imagePublisher,var.OSVersion) == "MicrosoftWindowsServer" ? 0 : 1
    name = local.vmName
    resource_group_name = azurerm_resource_group.arg-01.name
    location = azurerm_resource_group.arg-01.location
    vm_size = local.vmSize
    network_interface_ids = [azurerm_network_interface.ani-01.id]
    delete_os_disk_on_termination     = true
    delete_data_disks_on_termination  = true
    os_profile {
        computer_name = local.vmName
        admin_username = var.adminUsername
        admin_password = var.adminPassword
    }                               
    os_profile_linux_config {
    disable_password_authentication = false
    }
    storage_image_reference {
        publisher = lookup (var.imagePublisher,var.OSVersion)
        offer = lookup (var.imageOffer,var.OSVersion)
        sku = var.OSVersion
        version = "latest"
    }
    storage_os_disk {
        name = local.osDiskName
        create_option = "FromImage"
    }
}

## Output
# Hostname
output "hostname" {
  value = azurerm_public_ip.apip-01.fqdn
}
