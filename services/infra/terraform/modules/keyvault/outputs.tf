output "vault_uri" {
  value = azurerm_key_vault.main.vault_uri
}

output "eventhub_secret_id" {
  value = azurerm_key_vault_secret.eventhub_connection_string.id
}

output "key_vault_id" {
  value = azurerm_key_vault.main.id
}