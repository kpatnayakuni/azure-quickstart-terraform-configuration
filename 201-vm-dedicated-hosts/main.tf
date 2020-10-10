# Defining local variables
locals {
  numberOfHosts = var.numberOfZoness == "0" ? var.numberofHostsPerZone : var.numberOfZoness * var.numberofHostsPerZone
}

# Resource Group
resource "azurerm_resource_group" "arg-01" {
  name     = var.resourceGroupName
  location = var.location
}

# Dedicated host group
resource "azurerm_dedicated_host_group" "HostGroups" {
  count                       = var.numberOfZoness == "0" ? 1 : var.numberOfZoness
  name                        = "${var.dhgNamePrefix}${count.index}"
  resource_group_name         = azurerm_resource_group.arg-01.name
  location                    = azurerm_resource_group.arg-01.location
  platform_fault_domain_count = var.numberOfFDs
  zones                       = var.numberOfZoness == "0" ? [] : ["${count.index + 1}"]
}

# Dedicated host
resource "azurerm_dedicated_host" "host" {
  count                   = local.numberOfHosts
  name                    = join("",[var.dhgNamePrefix,floor(count.index/var.numberofHostsPerZone),"/",var.dhNamePrefix,floor(count.index/var.numberofHostsPerZone),count.index % var.numberOfFDs])
  # name = join("" ,[var.dhgNamePrefix-${count.index}/var.numberofHostsPerZone,"/",var.dhNamePrefix,${count.index}/var.numberofHostsPerZone,${count.index} % var.numberofHostsPerZone]-${count.index})
  location                = azurerm_resource_group.arg-01.location
  dedicated_host_group_id = element(azurerm_dedicated_host_group.HostGroups.*.id, floor(count.index / var.numberofHostsPerZone))
  sku_name                = var.dhSKU
  platform_fault_domain   = count.index % var.numberOfFDs
}


