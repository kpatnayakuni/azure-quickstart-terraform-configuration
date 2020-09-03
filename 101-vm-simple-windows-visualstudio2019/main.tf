
# Crete vm in existing resources
module "AddVMtoexistingVnet" {
  count                    = var.sharedResources == "existing" ? 1 : 0
  source                   = "./vm-existing-vnet"
  resourceGroupName        = "tf-rg"
  vmName                   = "simpleWinVS"
  vmsize                   = "Standard_D2_v2"
  adminUsername            = var.admin_username
  adminPassword            = var.adminPassword
  virtualNetworkName       = "vNet"
  subnetName               = "subnet"
  dnsLabelPrefix           = "demosep2020"
  networkSecurityGroupName = "SecGroupNet"
  subnetAddressRange       = "10.1.2.0/24"
  publicIPAddressName      = "publicip"
}

#Create vm in new resources
module "AddVMtNewVnet" {
  count                    = var.sharedResources == "new" ? 1 : 0
  source                   = "./vm-new-vnet"
  resourceGroupName        = "tf-rg"
  vmName                   = "simpleWinVS"
  vmsize                   = "Standard_D2_v2"
  adminUsername            = var.admin_username
  adminPassword            = var.adminPassword
  location                 = "westus"
  virtualNetworkName       = "vNet"
  subnetName               = "subnet"
  dnsLabelPrefix           = "demosep2020"
  networkSecurityGroupName = "SecGroupNet"
  addressPrefix            = "10.1.0.0/16"
  subnetAddressRange       = "10.1.2.0/24"
  publicIPAddressName      = "publicip"
}















