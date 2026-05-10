output "connection_string" {
  value     = azurerm_eventhub_namespace_authorization_rule.main.primary_connection_string
  sensitive = true
}
output "namespace_id" {
  value = azurerm_eventhub_namespace.main.id
}