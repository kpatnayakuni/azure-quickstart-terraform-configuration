---
summaryTitle: "101-vm-secure-password"
title: "Terraform: 101-vm-secure-password"
date: 2020-09-10
author: "Kiran Patnayakuni"
otherAuthors:
    author1:
        name: Anusha Dokula
        url: "/authors/anusha"
    author2: 
        name: Veeresh Setty
        url: "/authors/veeresh"
hideLastModified: false
tags: ["Terraform", "IaC", "AzureKeyVault","secure Passwrord"]
categories: ["Terraform", "Projects", "Azure"]
allowComments: true
weight: 481
githubLink: https://github.com/kpatnayakuni/azure-quickstart-terraform-configuration/tree/master/101-vm-secure-password
summaryImage: summaryImage.png
summary: "This is a conversion of ARM template Very simple deployment of a Windows VM from the GitHub repository azure\\azure-quickstart-templates to Terraform configuration, and this configuration will deploy following the resources..."
---

## Very simple deployment of a Windows VM

## Description

This is a conversion of ARM template {{< link "Very simple deployment of a Windows VM" "https://github.com/Azure/azure-quickstart-templates/tree/master/101-vm-secure-password" >}} from the repository {{< link "azure\azure-quickstart-templates" "https://github.com/Azure/azure-quickstart-templates" >}} to Terraform configuration.

<description>

{{< figure src="resources.png" width="<590>" >}}

> ### Note:
> If the specified resource group is already exist then the script will not continue with the deployment. If you want to deploy the resources to the existing resource group, then import the resource group to state before deployment.

## Syntax
{{< codeWide language="plain" >}}# To initialize the configuration directory
PS C:\Terraform\101-vm-secure-password> terraform init 

# To check the execution plan
PS C:\Terraform\101-vm-secure-password> terraform plan

# To deploy the configuration
PS C:\Terraform\101-vm-secure-password> terraform apply
{{< /codeWide >}}

## Example
{{< codeWide language="plain" >}}# Initialize
PS C:\Terraform\101-vm-secure-password> terraform init 

# Plan
PS C:\Terraform\101-vm-secure-password> terraform plan -var="adminUsername=cloudguy" 

<--- output truncated --->

# Apply
PS C:\Terraform\101-vm-secure-password> terraform apply -var="adminUsername=cloudguy" 
{{< /codeWide >}}

## Output
{{< codeWide language="plaintext" line-numbers="false" >}}azurerm_resource_group.arg-01: Creating...
azurerm_resource_group.arg-01: Creation complete after 1s
azurerm_public_ip.apip-01: Creating...
azurerm_virtual_network.avn-01: Creating...

<--- output truncated --->

azurerm_virtual_machine_data_disk_attachment.adattach-01: Still creating... [1m0s elapsed]
azurerm_virtual_machine_data_disk_attachment.adattach-01: Creation complete after 1m2s 

Apply complete! Resources: 12 added, 0 changed, 0 destroyed.
{{< /codeWide >}}

## Code
{{< ghbuttonV3 >}}
