
variable "neworexisting" {
type = string 
default = "new"

}
#Crete vm in existing vnet
module "AddVMtoexistingVnet" {
count = var.neworexisting == "existing" ? 1 : 0
source = "./vm-existing-vnet"
resourceGroupName = "tf-rg"
vmName = "simpleWinVS"
vmsize = "Standard_D2_v2"
adminUsername = "cloudguy"
adminPassword = "*********"
location = "westus"
virtualNetworkName = "vNet"
subnetName  = "subnet"
dnsLabelPrefix = "demosep2020"
networkSecurityGroupName = "SecGroupNet"
}
#Create vm in new vnet
module "AddVMtNewVnet" {
count = var.neworexisting == "new" ? 1 : 0
source = "./vm-new-vnet"
resourceGroupName = "tf-rg1"
vmName = "simpleWinVS"
vmsize = "Standard_D2_v2"
adminUsername = "cloudguy"
adminPassword = "********"
location = "westus"
virtualNetworkName = "vNet"
subnetName  = "subnet"
dnsLabelPrefix = "demosep2020"
networkSecurityGroupName = "SecGroupNet"

}