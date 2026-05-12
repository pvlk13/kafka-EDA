terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "resource_group" {
  source   = "./modules/resource-group"
  name     = var.resource_group_name
  location = var.location
}

module "acr" {
  source              = "./modules/acr"
  name                = var.acr_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
}

module "eventhubs" {
  source              = "./modules/eventhubs"
  namespace_name      = var.eventhubs_namespace_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
}

module "postgresql" {
  source              = "./modules/postgresql"
  allowed_ip          = var.allowed_ip
  name                = var.postgresql_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  admin_username      = var.postgresql_admin_username
  admin_password      = var.postgresql_admin_password
}

module "container_apps" {
  source                        = "./modules/container-apps"
  resource_group_name           = module.resource_group.name
  location                      = module.resource_group.location
  acr_login_server              = module.acr.login_server
  acr_admin_username            = module.acr.admin_username
  acr_admin_password            = module.acr.admin_password
  eventhub_connection_string    = module.eventhubs.connection_string
  eventhub_secret_id            = module.keyvault.eventhub_secret_id
  key_vault_id                  = module.keyvault.key_vault_id
  appinsights_connection_string = module.monitoring.connection_string
  db_password                   = var.postgresql_admin_password
  db_password_secret_id         = "https://vijaya-keyvault.vault.azure.net/secrets/db-password/33bb12fe9cee4642a65469175917ed09"
  appinsights_secret_id         = "https://vijaya-keyvault.vault.azure.net/secrets/appinsights-connection-string/07092cc90de34e2887ea4bfed2438869"
  allowed_ip                    = var.allowed_ip
  eventhub_namespace_id = module.eventhubs.namespace_id
  acr_id                = module.acr.acr_id
  
}  

module "keyvault" {
  source              = "./modules/keyvault"
  allowed_ip          = var.allowed_ip        
  name                = "vijaya-keyvault"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  postgres_password   = module.postgresql.admin_password  
  eventhub_connection_string = module.eventhubs.connection_string
  postgresql_admin_password  = var.postgresql_admin_password
  acr_password         = module.acr.admin_password
  db_password                  = var.postgresql_admin_password
  appinsights_connection_string = module.monitoring.connection_string
}

module "monitoring" {
  source              = "./modules/monitoring"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  order_service_url   = module.container_apps.order_service_url
  driver_service_url  = module.container_apps.driver_service_url
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  key_vault_id = module.keyvault.key_vault_id
  alert_email = var.alert_email
  azurerm_key_vault = module.keyvault.key_vault_id
}