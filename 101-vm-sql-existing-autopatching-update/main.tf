# Retrive information about existing VM
data "azurerm_virtual_machine" "avm-01" {
  name                = var.existingVirtualMachineName
  resource_group_name = var.resourceGroupName
}

# Updating auto patching settings of SqlIaaSagent
resource "azurerm_virtual_machine_extension" "azex-01" {
  name                 = "SqlIaasExtension"
  virtual_machine_id   = data.azurerm_virtual_machine.avm-01.id
  publisher            = "Microsoft.SqlServer.Management"
  type                 = "SqlIaaSAgent"
  type_handler_version = "1.2"
  settings             = <<SETTINGS
     { 
         "AutoTelemetrySettings": {
            "Region": "${var.location}"
          },
          "AutoPatchingSettings": {
            "PatchCategory": "WindowsMandatoryUpdates",
            "Enable": true,
            "DayOfWeek": "${var.sqlAutopatchingDayOfWeek}",
            "MaintenanceWindowStartingHour": "${var.sqlAutopatchingStartHour}",
            "MaintenanceWindowDuration": "${var.sqlAutopatchingWindowDuration}"
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
  protected_settings   = <<PROTECTED_SETTINGS
    {
    "protectedSettings": {}
    }
  PROTECTED_SETTINGS
}
