output "id" {
  description = "Resource ID of the key vault."
  value       = azurerm_key_vault.this.id
}

output "name" {
  description = "Name of the key vault."
  value       = azurerm_key_vault.this.name
}

output "vault_uri" {
  description = "URI of the key vault for client use, https://<name>.vault.azure.net/."
  value       = azurerm_key_vault.this.vault_uri
}
