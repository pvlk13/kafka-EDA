variable "name" {
  
}
variable "resource_group_name" {
  
}
variable "location" {
  
}
variable "eventhub_connection_string" {
  sensitive = true
}
variable "postgresql_admin_password" {
  sensitive = true
  
}
variable "acr_password" {
  sensitive = true
  
}
variable "postgres_password" {
    sensitive = true  
}
variable "db_password" {
    sensitive = true  
}
variable "appinsights_connection_string" {
    sensitive = true
} 

variable "allowed_ip" {
  type        = string
  description = "Allowed IP address for Key Vault network ACLs"
}