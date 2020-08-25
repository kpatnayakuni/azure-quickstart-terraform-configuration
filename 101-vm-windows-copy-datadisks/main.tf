# Defining the local variables
locals {
    imagePublisher = "MicrosoftWindowsServer"
    imageOffer = "WindowsServer"
    nicName = "myVMNic"
    addressPrefix = "10.0.0.0/16"
    subnetName = "Subnet"
    subnetPrefix = "10.0.0.0/24"
    publicIPAddressName = "myPublicIP"
    publicIPAddressType = "Dynamic"
    vmName = "VMDataDisks"
    vmSize = "Standard_DS4_v2"
    virtualNetworkName = "MyVNET"
    networkSecurityGroupName = "default-NSG"
    dnsLabelPrefix = lower(join("", ["ddvm-", random_string.vmd.result]))
}

# Resource Group
resource "azurerm_resource_group" "arg-01" {
    name        = var.resourceGroupName
    location    = var.location
}

# Generate random string for DNS Prefix
resource "random_string" "vmd" {
  length  = 16
  special = "false"
}

# Public IP
resource "azurerm_public_ip" "apip-01" {
    name                = local.publicIPAddressName
    resource_group_name = azurerm_resource_group.arg-01.name
    location            = azurerm_resource_group.arg-01.location
    allocation_method   = local.publicIPAddressType
    domain_name_label   = local.dnsLabelPrefix
}

# Network Security group
resource "azurerm_network_security_group" "ansg-01" {
    name                = local.networkSecurityGroupName
    resource_group_name = azurerm_resource_group.arg-01.name
    location            = azurerm_resource_group.arg-01.location
    security_rule {
        name                        = "default-allow-3389"
        priority                    = 1000
        access                      = "Allow"
        direction                   = "Inbound"
        destination_port_range      = 3389
        protocol                    = "Tcp"
        source_port_range           = "*"
        source_address_prefix       = "*"
        destination_address_prefix  = "*"
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
    name                  = local.subnetName
    resource_group_name   = azurerm_resource_group.arg-01.name
    virtual_network_name  = azurerm_virtual_network.avn-01.name
    address_prefixes        = [local.subnetPrefix]
}

# Associate subnet and network security group 
resource "azurerm_subnet_network_security_group_association" "asnsga-01" {
    subnet_id                   = azurerm_subnet.as-01.id
    network_security_group_id   = azurerm_network_security_group.ansg-01.id
}

# Network interface with IP configuration
resource "azurerm_network_interface" "anic-01" {
    name                = local.nicName
    resource_group_name = azurerm_resource_group.arg-01.name
    location            = azurerm_resource_group.arg-01.location
    ip_configuration {
        name                            = "ipconfig1"
        private_ip_address_allocation   = "Dynamic"
        public_ip_address_id            = azurerm_public_ip.apip-01.id
        subnet_id                       = azurerm_subnet.as-01.id
    }
}

# Virtual Machine
resource "azurerm_virtual_machine" "avm-01" {
    name                    = local.vmName
    resource_group_name = azurerm_resource_group.arg-01.name
    location            = azurerm_resource_group.arg-01.location
    vm_size                 = local.vmSize
    network_interface_ids   = [azurerm_network_interface.anic-01.id]
    os_profile {
        computer_name   = local.vmName
        admin_username  = var.adminUsername
        admin_password  = var.adminPassword
    }
    storage_image_reference {
        publisher = local.imagePublisher
        offer = local.imageOffer
        sku = var.OSVersion[1]
        version = "latest"
    }
    storage_os_disk {
        name            = "${local.vmName}_OSDisk"
        create_option   = "FromImage"
        disk_size_gb = 128
    }
    os_profile_windows_config {
        provision_vm_agent  = true
    }
}

# Managed disk
resource "azurerm_managed_disk" "amd-01" {
    count = var.numberOfDataDisks
    name = "${local.vmName}DataDisks${count.index}"
    resource_group_name     = azurerm_resource_group.arg-01.name
    location                = azurerm_resource_group.arg-01.location
    create_option   = "Empty"
    disk_size_gb    = 1023
    storage_account_type = "StandardSSD_LRS"
}

# Attaching managed disk to virtual_machine
resource "azurerm_virtual_machine_data_disk_attachment" "adattach-01" {
    count = var.numberOfDataDisks
    managed_disk_id = element(azurerm_managed_disk.amd-01.*.id, count.index)
    virtual_machine_id = azurerm_virtual_machine.avm-01.id
    caching = "ReadWrite"
    lun = count.index
} 

## Output
# Host FQDN
output "hostname" {
    value   = azurerm_public_ip.apip-01.fqdn
} 