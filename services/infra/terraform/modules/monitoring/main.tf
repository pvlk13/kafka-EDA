
# ✅ 1. Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name = "delivery-logs"
  resource_group_name = var.resource_group_name
  location = var.location
  sku = "PerGB2018"
  retention_in_days = 30
}

# ✅ 2. Application Insights
resource "azurerm_application_insights" "main" {
    name = "delivery-insights"
    resource_group_name = var.resource_group_name
    location = var.location
    workspace_id = azurerm_log_analytics_workspace.main.id
    application_type = "web"
  
}

# ✅ 3. Action Group 
resource "azurerm_monitor_action_group" "main" {
    name = "delivery-alerts"
    resource_group_name = var.resource_group_name
    short_name = "delivery"
    email_receiver {
        name = "admin"
        email_address = var.alert_email
    }
}
# ✅ 4. Availability test order-service
# ✅ 4. Availability test order-service
resource "azurerm_application_insights_standard_web_test" "order_service" {
  name                    = "order-service-availability"
  resource_group_name     = var.resource_group_name
  location                = var.location
  application_insights_id = azurerm_application_insights.main.id
  geo_locations           = ["emea-nl-ams-azr", "emea-gb-db3-azr", "us-ca-sjc-azr"]
  frequency               = 300
  timeout                 = 30
  enabled                 = true

  request {
    url = "https://${var.order_service_url}/health"
  }
}
# ✅ 5. Availability test driver-service
resource "azurerm_application_insights_standard_web_test" "driver_service" {
  name                    = "driver-service-availability"
  resource_group_name     = var.resource_group_name
  location                = var.location
  application_insights_id = azurerm_application_insights.main.id
  geo_locations           = ["emea-nl-ams-azr", "emea-gb-db3-azr", "us-ca-sjc-azr"]
  frequency               = 300
  timeout                 = 30
  enabled                 = true

  request {
    url = "https://${var.driver_service_url}/health"
  }
}

# ✅ 6. Alert - order-service down
resource "azurerm_monitor_metric_alert" "order_service_availability" {
  name                = "order-service-down"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights.main.id]
  severity            = 0
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "microsoft.insights/components"
    metric_name      = "availabilityResults/availabilityPercentage"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 100
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}

# ✅ 7. Alert - hoge error rate
resource "azurerm_monitor_metric_alert" "high_error_rate" {
  name                = "high-error-rate"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights.main.id]
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "microsoft.insights/components"
    metric_name      = "requests/failed"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = 10
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}
# ✅ 8. Alert - driver-service down
resource "azurerm_monitor_metric_alert" "driver_service_availability"{
    name = "driver-service-down"
    resource_group_name = var.resource_group_name
    scopes = [azurerm_application_insights.main.id]
    severity = 0 
    frequency = "PT15M"
    window_size = "PT15M"
    description = "Driver service is down"
    criteria {
        metric_namespace = "microsoft.insights/components"
        metric_name = "availabilityResults/availabilityPercentage"
        aggregation = "Average"
        operator = "LessThan"
        threshold = 100
    }

    action {
        action_group_id = azurerm_monitor_action_group.main.id
        
        }

}
# ✅ 9. Alert - high response time
resource "azurerm_monitor_metric_alert" "slow_response_time" {
    name = "slow-response-time"
    resource_group_name = var.resource_group_name
    scopes = [azurerm_application_insights.main.id]
    severity = 2 
    frequency = "PT15M"
    window_size = "PT15M"
    description = "High response time detected"
    criteria {
        metric_namespace = "microsoft.insights/components"
        metric_name = "requests/duration"
        aggregation = "Average"
        operator = "GreaterThan"
        threshold = 2000
    }

    action {
        action_group_id = azurerm_monitor_action_group.main.id
        
        }
}