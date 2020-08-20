
# Terraform: 101-vm-simple-linux
## Very simple deployment of a Linux VM 
## Description
This is a conversion of ARM template *[101-vm-simple-linux](https://github.com/Azure/azure-quickstart-templates/tree/master/101-vm-simple-linux)* from the repository *[azure\azure-quickstart-templates](https://https://github.com/Azure/azure-quickstart-templates)* to Terraform configuration.

This configuration deploys a Linux VM Ubuntu using the latest patched version. This will deploy a Standard_B2s size VM and a 18.04-LTS Version as defaultValue in the resource group location and will return the admin user name, Virtual Network Name, Network Security Group Name and FQDN.


This configuration will deploy the following resources...

![output](images/simplelinux.png)

> ### Note:
> If there is already the specified resource group exists then the script will not continue with the deployment. If you want to deploy the resources to the existing resource group, then import the resource group to state before the deployment.

### Syntax
```
# To initialize the configuration directory
PS C:\Terraform\101-vm-simple-linux> terraform init 

# To check the execution plan
PS C:\Terraform\101-vm-simple-linux> terraform plan

# To deploy the configuration
PS C:\Terraform\101-vm-simple-linux> terraform apply
```  

### Example
```
PS C:\Terraform\101-vm-simple-linux> terraform init 
PS C:\Terraform\101-vm-simple-linux> terraform plan

var.adminPassword
Password for the Virtual Machine.
Enter a value: *********

<--- output truncated --->

PS C:\Terraform\101-vm-simple-linux> terraform apply 

var.adminPassword
Password for the Virtual Machine.
Enter a value: *********
````

>Assuming public key is already generated and stored in your home directory ("~/.ssh/")

### Output
```
azurerm_linux_virtual_machine.avm-ssh-01[0]: Creating...
azurerm_linux_virtual_machine.avm-ssh-01[0]: Still creating... [10s elapsed]

<--- output truncated --->

azurerm_linux_virtual_machine.avm-ssh-01[0]: Still creating... [1m40s elapsed]
azurerm_linux_virtual_machine.avm-ssh-01[0]: Creation complete after 1m49s 

Apply complete! Resources: 9 added, 0 changed, 0 destroyed.

Outputs:

adminUsername = testing
hostname = simplelinuxvm-nhemg3r4nzsoifsy.westus.cloudapp.azure.com
```

>Azure Cloud Shelll comes with terraform pre-installed and you deploy this configuration in Cloud Shell as well.
>
>[![cloudshell](images/cloudshell.png)](https://shell.azure.com)