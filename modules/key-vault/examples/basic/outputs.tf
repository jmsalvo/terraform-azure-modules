output "id" {
  description = "Resource ID of the key vault."
  value       = module.key_vault.id
}

output "vault_uri" {
  description = "URI of the key vault."
  value       = module.key_vault.vault_uri
}
