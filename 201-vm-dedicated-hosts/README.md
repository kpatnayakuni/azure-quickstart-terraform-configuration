# Terraform: 201-vm-dedicated-hosts
## Azure Dedicated Hosts sample template.
## Description 

This is an Azure quickstart sample terraform configuration based on ARM template *[201-vm-dedicated-hosts](https://github.com/Azure/azure-quickstart-templates/tree/master/201-vm-dedicated-hosts)* from the repository *[azure\azure-quickstart-templates](https://github.com/Azure/azure-quickstart-templates)*.

This configuration provisions a dedicated environment using Azure Dedicated Hosts. You provide the number of zones, how many hosts in each zone and the rest is taken care of by the configuration.

> ### Note:
>This is the infrastructure only, no VMs or other resources will be provisioned.

### Syntax
```
# To initialize the configuration directory
PS C:\Terraform\201-vm-dedicated-hosts> terraform init 

# To check the execution plan
PS C:\Terraform\201-vm-dedicated-hosts terraform plan

# To deploy the configuration
PS C:\Terraform\201-vm-dedicated-hosts> terraform apply
```
### Example
```
# Initialize
PS C:\Terraform\201-vm-dedicated-hosts> terraform init 

# Plan
PS C:\Terraform\201-vm-dedicated-hosts> terraform plan 

<--- output truncated --->

# Apply
PS C:\Terraform\201-vm-dedicated-hosts> terraform apply
```
### Output
```
azurerm_dedicated_host_group.HostGroups[0]: Creating...

<--- output truncated --->

azurerm_dedicated_host.host[0]: Creation complete after 1m51s

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
```

>Azure Cloud Shelll comes with terraform pre-installed and you deploy this configuration in Cloud Shell as well.
>
>[![](https://shell.azure.com/images/launchcloudshell.png "Launch Azure Cloud Shell")](https://shell.azure.com)