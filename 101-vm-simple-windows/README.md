Cloud Shelll has in-built terraform libraries, deploy these configurations on Cloud Shell

[![cloudshell](cloudshell.png)](https://shell.azure.com)

# Terraform:101-vm-simple-windows

## Very simple deployment of a Windows VM
### Description 
 This is a conversion of ARM template *[101-vm-simple-windows](https://github.com/Azure/azure-quickstart-templates/tree/master/101-vm-simple-windows)* from the repository *[azure\azure-quickstart-templates](https://github.com/Azure/azure-quickstart-templates)*  to Terraform Script, and this script will deploy following the resources…
 
![result](example.png)

> ### Note:
> If there is already the specified resource group exists then the script will not continue with the deployment.If you want to deploy the resources to the existing resource group, import the resource 
group to state before deployment.

### Syntax
  ```
   terraform init 
   terraform plan
   terraform apply
 ```  

 ### Example
 ```
 PS C:\Terraform\Terraform> terraform init 
 PS C:\Terraform\Terraform> terraform plan

  var.adminPassword
  Password for the Virtual Machine.
  Enter a value: *********

 PS C:\Terraform\Terraform> terraform apply 

  var.adminPassword
  Password for the Virtual Machine.
  Enter a value: *********
````

### Output

```
azurerm_virtual_machine.avm-01: Creating...
azurerm_virtual_machine.avm-01: Still creating... [10s elapsed]
azurerm_virtual_machine.avm-01: Creation complete after 2m2s 

Apply complete! Resources: 9 added, 0 changed, 0 destroyed.

Outputs:

hostname = demodns2020.westus.cloudapp.azure.com
```
