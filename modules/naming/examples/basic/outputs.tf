output "names" {
  description = "Full map of generated resource names."
  value       = module.naming.names
}

output "tags" {
  description = "Merged tag map returned by the module."
  value       = module.naming.tags
}

output "resource_group_name" {
  description = "Generated resource group name."
  value       = module.naming.resource_group_name
}
