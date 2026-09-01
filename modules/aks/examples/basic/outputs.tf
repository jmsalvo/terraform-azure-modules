output "id" {
  description = "Resource ID of the AKS cluster."
  value       = module.aks.id
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL for configuring workload identity federated credentials."
  value       = module.aks.oidc_issuer_url
}

output "kubelet_identity_object_id" {
  description = "Kubelet identity object ID (e.g. for granting AcrPull)."
  value       = module.aks.kubelet_identity_object_id
}
