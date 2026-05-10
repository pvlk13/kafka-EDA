variable "name" {}
variable "resource_group_name" {}
variable "location" {}
variable "admin_username" {}
variable "admin_password" {
  sensitive = true
}
variable "allowed_ip" {}