resource "azurerm_container_registry" "main" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard" # standard is the most cost effective SKU for development and testing, for production use premium SKU which has more features and better performance
  admin_enabled       = true
}