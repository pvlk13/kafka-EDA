#!/bin/bash
set -e

echo "🔄 Importing all resources..."

terraform import module.resource_group.azurerm_resource_group.main \
  "/subscriptions/a63ecbe4-0d31-47d1-a4a9-dd608e7cf3e2/resourceGroups/vijaya-rg-container-apps"

terraform import module.acr.azurerm_container_registry.main \
  "/subscriptions/a63ecbe4-0d31-47d1-a4a9-dd608e7cf3e2/resourceGroups/vijaya-rg-container-apps/providers/Microsoft.ContainerRegistry/registries/vijaya1234acr"

terraform import module.eventhubs.azurerm_eventhub_namespace.main \
  "/subscriptions/a63ecbe4-0d31-47d1-a4a9-dd608e7cf3e2/resourceGroups/vijaya-rg-container-apps/providers/Microsoft.EventHub/namespaces/vijaya-eh12-namespace"

terraform import module.eventhubs.azurerm_eventhub.order_topic \
  "/subscriptions/a63ecbe4-0d31-47d1-a4a9-dd608e7cf3e2/resourceGroups/vijaya-rg-container-apps/providers/Microsoft.EventHub/namespaces/vijaya-eh12-namespace/eventhubs/order-topic"

terraform import module.eventhubs.azurerm_eventhub_namespace_authorization_rule.main \
  "/subscriptions/a63ecbe4-0d31-47d1-a4a9-dd608e7cf3e2/resourceGroups/vijaya-rg-container-apps/providers/Microsoft.EventHub/namespaces/vijaya-eh12-namespace/authorizationRules/RootManageSharedAccessKey"

terraform import module.keyvault.azurerm_key_vault.main \
  "/subscriptions/a63ecbe4-0d31-47d1-a4a9-dd608e7cf3e2/resourceGroups/vijaya-rg-container-apps/providers/Microsoft.KeyVault/vaults/vijaya-keyvault"

terraform import module.postgresql.azurerm_postgresql_flexible_server.main \
  "/subscriptions/a63ecbe4-0d31-47d1-a4a9-dd608e7cf3e2/resourceGroups/vijaya-rg-container-apps/providers/Microsoft.DBforPostgreSQL/flexibleServers/vijaya-postgresql"

terraform import module.postgresql.azurerm_postgresql_flexible_server_database.main \
  "/subscriptions/a63ecbe4-0d31-47d1-a4a9-dd608e7cf3e2/resourceGroups/vijaya-rg-container-apps/providers/Microsoft.DBforPostgreSQL/flexibleServers/vijaya-postgresql/databases/deliverydb"

terraform import module.postgresql.azurerm_postgresql_flexible_server_firewall_rule.allow_azure \
  "/subscriptions/a63ecbe4-0d31-47d1-a4a9-dd608e7cf3e2/resourceGroups/vijaya-rg-container-apps/providers/Microsoft.DBforPostgreSQL/flexibleServers/vijaya-postgresql/firewallRules/allow-azure-services"

terraform import module.monitoring.azurerm_log_analytics_workspace.main \
  "/subscriptions/a63ecbe4-0d31-47d1-a4a9-dd608e7cf3e2/resourceGroups/vijaya-rg-container-apps/providers/Microsoft.OperationalInsights/workspaces/delivery-logs"

terraform import module.monitoring.azurerm_application_insights.main \
  "/subscriptions/a63ecbe4-0d31-47d1-a4a9-dd608e7cf3e2/resourceGroups/vijaya-rg-container-apps/providers/Microsoft.Insights/components/delivery-insights"

terraform import module.monitoring.azurerm_monitor_action_group.main \
  "/subscriptions/a63ecbe4-0d31-47d1-a4a9-dd608e7cf3e2/resourceGroups/vijaya-rg-container-apps/providers/Microsoft.Insights/actionGroups/delivery-alerts"

terraform import module.monitoring.azurerm_monitor_metric_alert.high_error_rate \
  "/subscriptions/a63ecbe4-0d31-47d1-a4a9-dd608e7cf3e2/resourceGroups/vijaya-rg-container-apps/providers/Microsoft.Insights/metricAlerts/high-error-rate"

terraform import module.monitoring.azurerm_monitor_metric_alert.order_service_availability \
  "/subscriptions/a63ecbe4-0d31-47d1-a4a9-dd608e7cf3e2/resourceGroups/vijaya-rg-container-apps/providers/Microsoft.Insights/metricAlerts/order-service-down"

terraform import module.container_apps.azurerm_container_app_environment.main \
  "/subscriptions/a63ecbe4-0d31-47d1-a4a9-dd608e7cf3e2/resourceGroups/vijaya-rg-container-apps/providers/Microsoft.App/managedEnvironments/delivery-env"

terraform import module.container_apps.azurerm_container_app.order_service \
  "/subscriptions/a63ecbe4-0d31-47d1-a4a9-dd608e7cf3e2/resourceGroups/vijaya-rg-container-apps/providers/Microsoft.App/containerApps/order-service-app"

terraform import module.container_apps.azurerm_container_app.driver_service \
  "/subscriptions/a63ecbe4-0d31-47d1-a4a9-dd608e7cf3e2/resourceGroups/vijaya-rg-container-apps/providers/Microsoft.App/containerApps/driver-service-app"

echo "✅ All imports done!"
