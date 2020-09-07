# Terraform: 101-vm-user-image-data-disks
## Create a Virtual Machine from a User Image
## Description 

This is a conversion of ARM template *[101-vm-user-image-data-disks](https://github.com/Azure/azure-quickstart-templates/tree/master/101-vm-user-image-data-disks)* from the repository *[azure\azure-quickstart-templates](https://github.com/Azure/azure-quickstart-templates)* to Terraform configuration.

> Prerequisite - The VHDs to be used for OS and data disks must be stored as page blob in an Azure Resource Manager storage account.

This configuration allows you to create virtual machines from the specified VHDs for OS and data disks. The disks used for your VM will be based on copies of the VHDs you specify in the configuration parameters. It first creates a managed image using the specified OS and data VHDs. Then, it creates a VM using the managed image. And also deploys a Virtual Network, Public IP addresses and a Network Interface in a user specified resource group, and it will deploy the following resources...

![output](resources.png)

### Syntax
```
# To initialize the configuration directory
PS C:\Terraform\101-vm-user-image-data-disks> terraform init 

# To check the execution plan
PS C:\Terraform\101-vm-user-image-data-disks> terraform plan

# To deploy the configuration
PS C:\Terraform\101-vm-user-image-data-disks> terraform apply
```

### Example
```
# Initialize
PS C:\Terraform\101-vm-user-image-data-disks> terraform init 

# Plan with an existing vnet
PS C:\Terraform\101-vm-user-image-data-disks> terraform plan -var="existingVnetName=existing-vnet01" -var="existing-rg=test-rg" -var="vnet-new-or-existing=existing"

  var.adminPassword
  Password for the Virtual Machine. SSH key is recommended
  Enter a value: *******

  var.admin_username
  Default Admin username
  Enter a value: demouser

  var.vnet-new-or-existing
  Select if this template needs a new VNet or will reference an existing VNet.
  Enter a value: existing

# Plan with a new vnet
PS C:\Terraform\101-vm-user-image-data-disks> terraform plan -var="vnet-new-or-existing=new"

  var.adminPassword
  Password for the Virtual Machine. SSH key is recommended
  Enter a value: *******

  var.admin_username
  Default Admin username
  Enter a value: demouser

  var.vnet-new-or-existing
  Select if this template needs a new VNet or will reference an existing VNet.
  Enter a value: new

# To deploy within an existing vnet
PS C:\Terraform\101-vm-user-image-data-disks> terraform apply -var="existingVnetName=existing-vnet01" -var="existing-rg=test-rg" -var="vnet-new-or-existing=existing"

  var.adminPassword
  Password for the Virtual Machine. SSH key is recommended
  Enter a value: *******

  var.admin_username
  Default Admin username
  Enter a value: demouser

  var.vnet-new-or-existing
  Select if this template needs a new VNet or will reference an existing VNet.
  Enter a value: existing

# To deploy within a new vnet
PS C:\Terraform\101-vm-user-image-data-disks> terraform apply -var="vnet-new-or-existing=new"

  var.adminPassword
  Password for the Virtual Machine. SSH key is recommended
  Enter a value: *******

  var.admin_username
  Default Admin username
  Enter a value: demouser

  var.vnet-new-or-existing
  Select if this template needs a new VNet or will reference an existing VNet.
  Enter a value: new
```

### Output
```
module.AddVMtoexistingVnet[0].data.azurerm_virtual_network.vnet-existing-01: Refreshing state...
module.AddVMtoexistingVnet[0].data.azurerm_subnet.asn-existing-01: Refreshing state...

<--- output truncated --->

module.AddVMtoexistingVnet[0].azurerm_virtual_machine.avm-existing-01: Still creating... [6m0s elapsed]
module.AddVMtoexistingVnet[0].azurerm_virtual_machine.avm-existing-01: Creation complete after 6m1s 


Apply complete! Resources: 5 added, 0 changed, 0 destroyed
```
>Azure Cloud Shelll comes with terraform pre-installed and you deploy this configuration in Cloud Shell as well.
>
>[![](https://shell.azure.com/images/launchcloudshell.png "Launch Azure Cloud Shell")](https://shell.azure.com)
