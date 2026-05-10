# ✅ Nieuw - stable URL
output "order_service_url" {
  value = azurerm_container_app.order_service.ingress[0].fqdn
}

output "driver_service_url" {
  value = azurerm_container_app.driver_service.ingress[0].fqdn
}
output "order_service_principal_id" {
  value = azurerm_container_app.order_service.identity[0].principal_id
}

output "driver_service_principal_id" {
  value = azurerm_container_app.driver_service.identity[0].principal_id
}