# Terraform: 201-2-vms-internal-load-balancer

## Create 2 Virtual Machines under an Internal Load balancer and configures Load Balancing rules for the VMs

## Description

This is a conversion of ARM template *[201-2-vms-internal-load-balancer](https://github.com/Azure/azure-quickstart-templates/tree/master/201-2-vms-internal-load-balancer)* from the repository *[azure\azure-quickstart-templates](https://github.com/Azure/azure-quickstart-templates)* to Terraform configuration.

This configuration allows you to create 2 Virtual Machines under an Internal Load balancer, and also deploys a Storage Account, Virtual Network, Availability Set and Network Interfaces. The Azure Load Balancer is assigned a static IP in the Virtual Network and is configured to load balance on Port 80, and it will deploy the following resources...

![output](resources.png)

> ### Note:
> If the specified resource group is already exist then the script will not continue with the deployment. If you want to deploy the resources to the existing resource group, then import the resource group to state before deployment.

### Syntax
```
# To initialize the configuration directory
PS C:\Terraform\201-2-vms-internal-load-balancer> terraform init 

# To check the execution plan
PS C:\Terraform\201-2-vms-internal-load-balancer> terraform plan

# To deploy the configuration
PS C:\Terraform\201-2-vms-internal-load-balancer> terraform apply
```  

### Example
```
# Initialize
PS C:\Terraform\201-2-vms-internal-load-balancer> terraform init 

# Plan
PS C:\Terraform\201-2-vms-internal-load-balancer> terraform plan

var.adminPassword
Password for the Virtual Machine.
Enter a value: *********

<--- output truncated --->

# Apply
PS C:\Terraform\201-2-vms-internal-load-balancer> terraform apply 

var.adminPassword
Password for the Virtual Machine.
Enter a value: *********
```

### Output
```
azurerm_virtual_machine.avm01: Creating...
azurerm_virtual_machine.avm01: Still creating... [10s elapsed]

<--- output truncated --->

azurerm_virtual_machine.avm01[0]: Creation complete after 3m6s

Apply complete! Resources: 17 added, 0 changed, 0 destroyed.
```

>Azure Cloud Shelll comes with terraform pre-installed and you deploy this configuration in Cloud Shell as well.
>
>[![](https://shell.azure.com/images/launchcloudshell.png "Launch Azure Cloud Shell")](https://shell.azure.com)