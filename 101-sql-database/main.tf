# Defining the local variables
locals {
  sqlserver = lower(join("", [var.SQLServer, random_string.srvname.result]))
}

# Random string for sqlserver name  
resource "random_string" "srvname" {
  length            = 16
  override_special  = "-"
}

# Resource Group
resource "azurerm_resource_group" "arg-01" {
  name     = var.resource_group_name
  location = var.location
}

# SQL Server 
resource "azurerm_sql_server" "SQL-Ser-01" {
  name                         = local.sqlserver
  resource_group_name          = azurerm_resource_group.arg-01.name
  location                     = azurerm_resource_group.arg-01.location
  version                      = "12.0"
  administrator_login          = var.administratorLogin
  administrator_login_password = var.administratorLoginPassword
}

# Azure SQL database
resource "azurerm_mssql_database" "SQL-Db-01" {
  name           = var.sqldbname
  server_id      = azurerm_sql_server.SQL-Ser-01.id
  sku_name       = "s0"  
}