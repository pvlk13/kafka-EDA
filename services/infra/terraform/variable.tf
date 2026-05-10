variable "resource_group_name" {
  default = "vijaya-rg-container-apps"
}

variable "location" {
  default = "westus"
}

variable "alert_email" {
  default = "itsmevijaya13@gmail.com"
}

variable "acr_name" {
  default = "vijaya1234acr"
}

variable "eventhubs_namespace_name" {
  default = "vijaya-eh12-namespace"
}

variable "postgresql_name" {
  default = "vijaya-postgresql"
}
variable "postgresql_admin_username" {
  default = "adminuser"
}

variable "postgresql_admin_password" {
  sensitive = true
}

variable "allowed_ip" {
  default = "62.45.86.198"
}

variable "container_apps_name" {
  type        = string
  description = "Name for the container apps"
}