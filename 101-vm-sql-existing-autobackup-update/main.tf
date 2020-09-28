# Using existing virtual machine
data "azurerm_virtual_machine" "avm-01" {
  name                = var.existingVirtualMachineName
  resource_group_name = var.resourceGroupName
}

# Using existing storage account
data "azurerm_storage_account" "asa-01" {
  name                = var.sqlAutobackupStorageAccountName
  resource_group_name = var.resourceGroupName
}

# Virtual machine extension
resource "azurerm_virtual_machine_extension" "avm-ext-01" {
  name                       = "SqlIaasExtension"
  virtual_machine_id         = data.azurerm_virtual_machine.avm-01.id
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
    "AutoBackupSettings": {
      "Enable": true,
      "RetentionPeriod": "${var.sqlAutobackupRetentionPeriod}",
      "EnableEncryption": true
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
  protected_settings         = <<PROTECTED_SETTINGS
  {
    "StorageUrl": "${data.azurerm_storage_account.asa-01.primary_blob_endpoint}",
    "StorageAccessKey": "${data.azurerm_storage_account.asa-01.primary_access_key}",
    "Password": "${var.sqlAutobackupEncryptionPassword}"   
  }
  PROTECTED_SETTINGS
}
