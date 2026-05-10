variable "resource_group_name" {}
variable "location" {}
variable "acr_login_server" {}
variable "acr_admin_username" {}
variable "acr_admin_password" {
  sensitive = true
}
variable "eventhub_connection_string" {
  sensitive = true
}
variable "eventhub_secret_id" {}
variable "key_vault_id" {}
variable "db_password_secret_id" {
  
}
variable "appinsights_secret_id" {}
variable "db_password" {
  sensitive = true
  
}
variable "appinsights_connection_string" {
  sensitive = true
  
}
variable "allowed_ip" {}
variable "eventhub_namespace_id" {
  type        = string
  description = "The ID of the Event Hub namespace"
}

variable "acr_id" {
  type        = string
  description = "The ID of the Azure Container Registry"
}