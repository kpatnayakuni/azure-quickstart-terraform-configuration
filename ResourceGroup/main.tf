resource "azurerm_resource_group" "arg-01" {
  name      = "test-rg"
  location  = "westus"
  tags = {
    Owner       = "Kiran Patnayakuni"
    Environment = "Test"
  }
}