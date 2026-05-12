variable "resource_group_name" {}
variable "location" {}
variable "order_service_url" {}
variable "driver_service_url" {}
variable "alert_email" {}
variable "key_vault_id" {
  type = string
}
variable "log_analytics_workspace_id" {
  type = string
}
variable "azurerm_key_vault" {
  type = any
}