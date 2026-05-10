data "azurerm_client_config" "current" {}

resource "azurerm_container_app_environment" "main" {
  name                = "delivery-env"
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_container_app" "order_service" {
  name                         = "order-service-app"
  resource_group_name          = var.resource_group_name
  container_app_environment_id = azurerm_container_app_environment.main.id
  revision_mode                = "Single"

  identity {
    type = "SystemAssigned"
  }

  registry {
    server               = var.acr_login_server
    username             = var.acr_admin_username
    password_secret_name = "acr-password"
  }

  secret {
    name  = "acr-password"
    value = var.acr_admin_password
  }

  secret {
    name  = "eventhub-connection-string"
    value = var.eventhub_connection_string
  }

  secret {
    name  = "db-password"
    value = var.db_password
  }

  secret {
    name  = "appinsights-connection-string"
    value = var.appinsights_connection_string
  }

  template {
    container {
      name   = "order-service"
      image  = "${var.acr_login_server}/order-service:latest"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name        = "EVENT_HUB_CONNECTION_STRING"
        secret_name = "eventhub-connection-string"
      }

      env {
        name        = "DB_PASSWORD"
        secret_name = "db-password"
      }

      env {
        name        = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        secret_name = "appinsights-connection-string"
      }

      env {
        name  = "DB_HOST"
        value = "vijaya-postgresql.postgres.database.azure.com"
      }

      env {
        name  = "DB_NAME"
        value = "deliverydb"
      }

      env {
        name  = "DB_USER"
        value = "adminuser"
      }
    }
  }

  ingress {
    external_enabled           = true
    target_port                = 3000
    transport                  = "http"
    allow_insecure_connections = false

    ip_security_restriction {
      name             = "allow-all-https"
      ip_address_range = "0.0.0.0/0"
      action           = "Allow"
      description      = "Allow all IPs over HTTPS"
    }

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

resource "azurerm_container_app" "driver_service" {
  name                         = "driver-service-app"
  resource_group_name          = var.resource_group_name
  container_app_environment_id = azurerm_container_app_environment.main.id
  revision_mode                = "Single"

  identity {
    type = "SystemAssigned"
  }

  registry {
    server               = var.acr_login_server
    username             = var.acr_admin_username
    password_secret_name = "acr-password"
  }

  secret {
    name  = "acr-password"
    value = var.acr_admin_password
  }

  secret {
    name  = "eventhub-connection-string"
    value = var.eventhub_connection_string
  }

  secret {
    name  = "db-password"
    value = var.db_password
  }

  secret {
    name  = "appinsights-connection-string"
    value = var.appinsights_connection_string
  }

  template {
    container {
      name   = "driver-service"
      image  = "${var.acr_login_server}/driver-service:latest"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name        = "EVENT_HUB_CONNECTION_STRING"
        secret_name = "eventhub-connection-string"
      }

      env {
        name        = "DB_PASSWORD"
        secret_name = "db-password"
      }

      env {
        name        = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        secret_name = "appinsights-connection-string"
      }

      env {
        name  = "DB_HOST"
        value = "vijaya-postgresql.postgres.database.azure.com"
      }

      env {
        name  = "DB_NAME"
        value = "deliverydb"
      }

      env {
        name  = "DB_USER"
        value = "adminuser"
      }
    }
  }

  ingress {
    external_enabled           = true
    target_port                = 3001
    transport                  = "auto"
    allow_insecure_connections = false

    ip_security_restriction {
      name             = "allow-all-https"
      ip_address_range = "0.0.0.0/0"
      action           = "Allow"
      description      = "Allow all IPs over HTTPS"
    }

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

resource "azurerm_role_assignment" "order_service_eventhub_sender"{
  scope = var.eventhub_namespace_id
  role_definition_name = "Azure Event Hubs Data Sender"
  principal_id = azurerm_container_app.order_service.identity[0].principal_id
}

resource "azurerm_role_assignment" "driver_service_eventhub_receiver" {
  scope     = var.eventhub_namespace_id
  role_definition_name = "Azure Event Hubs Data Receiver"
  principal_id = azurerm_container_app.driver_service.identity[0].principal_id
}
resource "azurerm_role_assignment" "order_service_keyvault" {
  scope = var.key_vault_id
  role_definition_name =  "Key Vault Secrets User"
  principal_id = azurerm_container_app.order_service.identity[0].principal_id 
  lifecycle {
    ignore_changes = all
  }
  
}
resource "azurerm_role_assignment" "driver_service_keyvault" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_container_app.driver_service.identity[0].principal_id
  lifecycle {
    ignore_changes = all
  }
}

# ✅ beide services mogen images pullen van ACR
resource "azurerm_role_assignment" "order_service_acr" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_container_app.order_service.identity[0].principal_id
}

resource "azurerm_role_assignment" "driver_service_acr" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_container_app.driver_service.identity[0].principal_id
}
