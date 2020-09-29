# Hostname 
output "hostname" {
  value = azurerm_public_ip.apip-01.fqdn
}
