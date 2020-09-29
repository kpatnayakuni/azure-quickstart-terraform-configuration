# Defining the local variables
locals {
  storageAccountName1 = lower(join("", [random_string.srg.result, "storage1"]))
  storageAccountName2 = lower(join("", [random_string.srg.result, "storage2"]))
  vmNSGName           = "ExistingNSG"
  ipAddressName       = "ExistingPip"
  virtualNetworkName  = "ExistingVnet"
  vmNicName           = "ExistingNic"
  vmName              = "ExistingWinvm"
}

# Generate random string for storage Prefix
resource "random_string" "srg" {
  length  = 16
  special = "false"
}

# Resource Group
resource "azurerm_resource_group" "arg-01" {
  name     = var.resourceGroupName
  location = var.location
}

# Storage account
resource "azurerm_storage_account" "asa-01" {
  name                     = local.storageAccountName1
  resource_group_name      = azurerm_resource_group.arg-01.name
  location                 = azurerm_resource_group.arg-01.location
  account_kind             = "storage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    displayName = "Storage Account"
  }
}

resource "azurerm_storage_account" "asa-02" {
  name                     = local.storageAccountName2
  resource_group_name      = azurerm_resource_group.arg-01.name
  location                 = azurerm_resource_group.arg-01.location
  account_kind             = "storage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    displayName = "Storage Account"
  }
}

# Network security group
resource "azurerm_network_security_group" "ansg-01" {
  name                = local.vmNSGName
  resource_group_name = azurerm_resource_group.arg-01.name
  location            = azurerm_resource_group.arg-01.location
  tags = {
    displayName = "VM NSG"
  }
}

# Public IP 
resource "azurerm_public_ip" "apip-01" {
  name                = local.ipAddressName
  resource_group_name = azurerm_resource_group.arg-01.name
  location            = azurerm_resource_group.arg-01.location
  allocation_method   = "Static"
  idle_timeout_in_minutes = 4
  tags = {
    displayName = "VM Public IP"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "avn-01" {
  name                = local.virtualNetworkName
  resource_group_name = azurerm_resource_group.arg-01.name
  location            = azurerm_resource_group.arg-01.location
  address_space       = ["10.0.0.0/16"]
  tags = {
    displayName = "Virtual Network"
  }
}

# Subnet
resource "azurerm_subnet" "as-01" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.arg-01.name
  virtual_network_name = azurerm_virtual_network.avn-01.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Associate subnet and network security group 
resource "azurerm_subnet_network_security_group_association" "asnsga-01" {
  subnet_id                 = azurerm_subnet.as-01.id
  network_security_group_id = azurerm_network_security_group.ansg-01.id
}

# Network interface with IP configuration
resource "azurerm_network_interface" "anic-01" {
  name                = local.vmNicName
  resource_group_name = azurerm_resource_group.arg-01.name
  location            = azurerm_resource_group.arg-01.location
  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.apip-01.id
    subnet_id                     = azurerm_subnet.as-01.id
  }
  tags = {
    displayName = "VM NIC"
  }
}

# Virtual Machine
resource "azurerm_virtual_machine" "avm-01" {
  name                  = local.vmName
  resource_group_name   = azurerm_resource_group.arg-01.name
  location              = azurerm_resource_group.arg-01.location
  vm_size               = "Standard_DS1_v2"
  network_interface_ids = [azurerm_network_interface.anic-01.id]
  os_profile {
    computer_name  = "windowsvm"
    admin_username = var.adminUsername
    admin_password = var.adminPassword
  }
  storage_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = "SQL2014SP2-WS2012R2"
    sku       = "Enterprise"
    version   = "latest"
  }
  storage_os_disk {
    name          = join("", [local.vmName, "_OsDisk"])
    create_option = "FromImage"
  }
  storage_data_disk {
    name          = join("", [local.vmName, "_DataDisk1"])
    disk_size_gb  = 1023
    lun           = 0
    create_option = "Empty"
    caching       = "ReadOnly"
  }
  os_profile_windows_config {
    provision_vm_agent = true
  }
  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.asa-01.primary_blob_endpoint
  }
  tags = {
    displayName = "Virtual Machine"
  }
}

# Azure virtual machine extension
resource "azurerm_virtual_machine_extension" "avm-ext-01" {
  name               = "SqlIaasExtension"
  virtual_machine_id = azurerm_virtual_machine.avm-01.id

  publisher                  = "Microsoft.SqlServer.Management"
  type                       = "SqlIaaSAgent"
  type_handler_version       = "1.2"
  auto_upgrade_minor_version = true
  settings                   = <<SETTINGS
   {
   "AutoTelemetrySettings": {
      "Region": "${var.location}"
    },
    "AutoPatchingSettings": {
      "PatchCategory": "WindowsMandatoryUpdates",
      "Enable": true,
      "DayOfWeek": "Sunday",
      "MaintenanceWindowStartingHour": "2",
      "MaintenanceWindowDuration": "60"
    },
    "KeyVaultCredentialSettings": {
    "Enable": false,
    "CredentialName": ""
    },
    "ServerConfigurationsManagementSettings": {
    "SQLConnectivityUpdateSettings": {
      "ConnectivityType": "Private",
      "Port": "1433"
     },
     "SQLWorkloadTypeUpdateSettings": {
      "SQLWorkloadType": "GENERAL"
     },
     "SQLStorageUpdateSettings": {
      "DiskCount": "1",
      "NumberOfColumns": "1",
      "StartingDeviceID": "2",
      "DiskConfigurationType": "NEW"
     },
     "AdditionalFeaturesServerConfigurations": {
      "IsRServicesEnabled": "false"
     }
    }
  }
  SETTINGS
  protected_settings  = <<PROTECTED_SETTINGS
  { }
  PROTECTED_SETTINGS
}

#Output 
output "existingVirtualMachineName" {
  value = local.vmName
}

output "sqlAutobackupStorageAccountName" {
  value = local.storageAccountName2
}
