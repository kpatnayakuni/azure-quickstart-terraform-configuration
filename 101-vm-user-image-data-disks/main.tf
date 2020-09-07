# Create vm in existing resources
module "AddVMtoexistingVnet" {
  count                                          = var.vnet-new-or-existing == "existing" ? 1 : 0
  source                                         = "./existing-vnet"
  adminUsername                                  = var.admin_username
  adminPassword                                  = var.adminPassword
  resourceGroupName                              = "test-rg"
  customVmName                                   = "demovm"
  bootDiagnosticsStorageAccountName              = "bootstoragename"
  bootDiagnosticsStorageAccountResourceGroupName = "bootdiagnostic-rg"
  osDiskVhdUri                                   = "https://demostorageaugust.blob.core.windows.net/democontainer/azvmimage.vhd"
  dataDiskVhdUri                                 = "https://demostorageaugust.blob.core.windows.net/democontainer/imgdatadisk.vhd"
  dnsLabelPrefix                                 = "demodnsaugust"
  vmSize                                         = "Standard_DS1_v2"
  diskStorageType                                = ["Standard_LRS", "Premium_LRS"]
  osType                                         = ["Windows", "Linux"]
  existingVnetName                               = "exisiting-vnet"
  existingsubnetName                             = "defaault"
  existingVnetResourceGroupName                  = "test-rg"
  publicIPAddressType                            = "Dynamic"
  imageName                                      = "myCustomImage"
}

#Create vm in new resources
module "AddVMtoNewVnet" {
  count                                          = var.vnet-new-or-existing == "new" ? 1 : 0
  source                                         = "./new-vnet"
  adminUsername                                  = var.admin_username
  adminPassword                                  = var.adminPassword
  resourceGroupName                              = "demo-rg"
  location                                       = "westus"
  customVmName                                   = "demovm"
  bootDiagnosticsStorageAccountName              = "bootstoragename"
  bootDiagnosticsStorageAccountResourceGroupName = "bootdiagnostic-rg"
  osDiskVhdUri                                   = "https://demostorageaugust.blob.core.windows.net/democontainer/azvmimage.vhd"
  dataDiskVhdUri                                 = "https://demostorageaugust.blob.core.windows.net/democontainer/imgdatadisk.vhd"
  dnsLabelPrefix                                 = "demodnsaugust"
  vmSize                                         = "Standard_DS1_v2"
  diskStorageType                                = ["Standard_LRS", "Premium_LRS"]
  osType                                         = ["Windows", "Linux"]
  newVnetName                                    = "new-vnet"
  newsubnetName                                  = "newsubnet"
  publicIPAddressType                            = "Dynamic"
  imageName                                      = "myCustomImage"
  addressPrefix                                  = "10.0.0.0/16"
  subnetPrefix                                   = "10.0.0.0/24"
}
