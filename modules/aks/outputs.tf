output "id" {
  description = "Resource ID of the AKS cluster."
  value       = azurerm_kubernetes_cluster.this.id
}

output "name" {
  description = "Name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.this.name
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL, used to configure federated credentials for workload identity."
  value       = azurerm_kubernetes_cluster.this.oidc_issuer_url
}

output "node_resource_group" {
  description = "Name of the auto-generated resource group holding the cluster's node resources."
  value       = azurerm_kubernetes_cluster.this.node_resource_group
}

output "kubelet_identity_object_id" {
  description = "Object ID of the kubelet managed identity (used for ACR pull role assignments, etc.)."
  value       = try(azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id, null)
}

output "identity_principal_id" {
  description = "Principal ID of the cluster's system-assigned managed identity."
  value       = try(azurerm_kubernetes_cluster.this.identity[0].principal_id, null)
}
