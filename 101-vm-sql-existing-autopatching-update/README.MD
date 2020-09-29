# Terraform: 101-vm-sql-existing-autopatching-update
## Configure Automated Patching on any existing Azure virtual machine.
## Description 
This is an Azure quickstart sample terraform configuration based on ARM template *[101-vm-sql-existing-autopatching-update](https://github.com/Azure/azure-quickstart-templates/tree/master/101-vm-sql-existing-autopatching-update)* from the repository *[azure\azure-quickstart-templates](https://github.com/Azure/azure-quickstart-templates)*.

This configuration can be used for any Azure virtual machine, whether it is running SQL Server or not. If your virtual machine is running SQL Server, it must be SQL Server 2012 or newer.

The Automated Patching feature can be used to schedule a patching window during which all Windows and SQL Server updates will take place.

This configuration can be used to enable or change the configuration of Automated Patching. Please ensure you have already deployed the prerequisite *[preq](https://github.com/Azure/azure-quickstart-templates/tree/master/101-vm-sql-existing-autopatching-update/prereqs)*

If you wish to disable Automated Patching, you must edit main.tf and change "Enable" to be false.


> ### Note:
> Before deploying this configuration, import the existing azure vm extension into the terraform state file to manage that resource by terraform.
> ex: terraform import azurerm_virtual_machine_extension.azex-01 < resource id >

### Syntax
```
# To initialize the configuration directory
PS C:\Terraform\101-vm-sql-existing-autopatching-update> terraform init 

# To check the execution plan
PS C:\Terraform\101-vm-sql-existing-autopatching-update> terraform plan

# To deploy the configuration
PS C:\Terraform\101-vm-sql-existing-autopatching-update> terraform apply
```

### Example
```
# Initialize
PS C:\Terraform\101-vm-sql-existing-autopatching-update> terraform init 

# Plan
PS C:\Terraform\101-vm-sql-existing-autopatching-update> terraform plan


# Apply
PS C:\Terraform\101-vm-sql-existing-autopatching-update> terraform apply

```
## Output
```
azurerm_virtual_machine_extension.azex-01: Modifying...
azurerm_virtual_machine_extension.azex-01: Still modifying..

<--- output truncated --->

azurerm_virtual_machine_extension.azex-01: Still modifying... 
azurerm_virtual_machine_extension.azex-01: Modifications complete after 2m2s 

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

> Azure Cloud Shell comes with Azure PowerShell pre-installed and you can deploy the above resources using Cloud Shell as well.
>
>[![](https://shell.azure.com/images/launchcloudshell.png "Launch Azure Cloud Shell")](https://shell.azure.com)
