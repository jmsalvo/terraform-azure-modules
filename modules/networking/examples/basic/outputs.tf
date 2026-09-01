output "vnet_id" {
  description = "Resource ID of the created virtual network."
  value       = module.networking.vnet_id
}

output "subnet_ids" {
  description = "Map of subnet name to subnet ID."
  value       = module.networking.subnet_ids
}

output "network_security_group_ids" {
  description = "Map of subnet name to associated NSG ID."
  value       = module.networking.network_security_group_ids
}
