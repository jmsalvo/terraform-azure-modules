output "names" {
  description = "Map of resource type to generated name. Dash-style for most types; compact and length-limited for storage_account, key_vault and container_registry."
  value       = local.names
}

output "tags" {
  description = "Baseline tags merged with the caller tags; the caller wins on key collisions."
  value       = local.tags
}

output "name_prefix" {
  description = "The dash-joined name stem shared by every generated name, for example shop-prod-eus2-001."
  value       = local.name_prefix
}

output "resource_group_name" {
  description = "Convenience accessor for names[\"resource_group\"]."
  value       = local.names.resource_group
}

output "key_vault_name" {
  description = "Convenience accessor for names[\"key_vault\"]."
  value       = local.names.key_vault
}

output "storage_account_name" {
  description = "Convenience accessor for names[\"storage_account\"]."
  value       = local.names.storage_account
}
