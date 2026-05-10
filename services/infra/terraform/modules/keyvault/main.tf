terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

data "azurerm_client_config" "current" {}
resource "azurerm_key_vault" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  access_policy {                                                    # ← geen = teken
    tenant_id = data.azurerm_client_config.current.tenant_id
    # ↑ van welke organisatie kom jij?
    object_id = data.azurerm_client_config.current.object_id
    # ↑ wie ben jij precies? (jouw Azure account ID)
    secret_permissions = ["Get", "List", "Set", "Delete"]
    # ↑ wat mag jij doen met de geheimen?
  }
  network_acls {
    default_action = "Deny"
    bypass = "AzureServices"
    ip_rules = [var.allowed_ip]
  }
}

resource "azurerm_key_vault_secret" "eventhub_connection_string" {
    name = "eventhub-connection-string"
    value = var.eventhub_connection_string
    key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_key_vault_secret" "postgres_password" {
    name = "postgres-password"
    value = var.postgres_password
    key_vault_id = azurerm_key_vault.main.id
  
}

resource "azurerm_key_vault_secret" "acr_password" {
    name = "acr-password"
    value = var.acr_password
    key_vault_id = azurerm_key_vault.main.id
  
}

# Appinsights secret 
resource "azurerm_key_vault_secret" "appinsights_connection_string"{
  name = "appinsights-connection-string"
  value = var.appinsights_connection_string
  key_vault_id = azurerm_key_vault.main.id
}
# DB password 
resource "azurerm_key_vault_secret" "db_password" {
  name = "db-password"
  value = var.db_password
  key_vault_id = azurerm_key_vault.main.id
}