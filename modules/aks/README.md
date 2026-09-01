# aks

A **hardened** Azure Kubernetes Service cluster, built as a building block for a
platform (it feeds the flagship's `v0.2` milestone).

## Hardening (all on by default)

- **Entra RBAC for Kubernetes** — `azure_rbac_enabled = true`, with optional
  `admin_group_object_ids`.
- **`local_account_disabled = true`** — no local Kubernetes admin; all access
  goes through Entra.
- **`private_cluster_enabled = true`** — the API server is not on the public
  internet.
- **OIDC issuer + workload identity** enabled — ready for federated credentials
  (no secrets for in-cluster workloads).
- **Azure Policy add-on** enabled.
- **System-assigned managed identity.**
- **Azure CNI** with a **network policy** engine (`calico` by default).

## Usage

```hcl
data "azurerm_client_config" "current" {}

module "aks" {
  source = "github.com/jmsalvo/terraform-azure-modules//modules/aks?ref=v0.1.0"

  name                        = "aks-shop-prod-eus2-001"
  resource_group_name         = "rg-shop-prod-eus2-001"
  location                    = "eastus2"
  dns_prefix                  = "shop-prod"
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  default_node_pool_subnet_id = module.networking.subnet_ids["aks"]

  admin_group_object_ids     = [var.platform_admins_group_id]
  log_analytics_workspace_id = module.observability.workspace_id

  default_node_pool = {
    vm_size   = "Standard_D4s_v5"
    min_count = 2
    max_count = 6
  }

  tags = module.naming.tags
}
```

Like the other modules, `aks` takes plain values and a subnet ID — compose it
with `naming` / `networking` in the root module.

## Scope

Out of scope for now (follow-ups): additional node pools, user-assigned identity,
control-plane diagnostic settings, maintenance windows, the Microsoft Defender
block, and API-server authorized IP ranges (a private cluster covers the common
case).

## Tests

```bash
terraform -chdir=modules/aks test
```

Tests use `mock_provider "azurerm"`, so they need no Azure credentials.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.6.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider_azurerm) | ~> 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_kubernetes_cluster.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_admin_group_object_ids"></a> [admin_group_object_ids](#input_admin_group_object_ids) | Entra group object IDs granted cluster-admin via Azure RBAC for Kubernetes. | `list(string)` | `[]` | no |
| <a name="input_azure_policy_enabled"></a> [azure_policy_enabled](#input_azure_policy_enabled) | Enable the Azure Policy add-on. | `bool` | `true` | no |
| <a name="input_default_node_pool"></a> [default_node_pool](#input_default_node_pool) | Default (system) node pool:<br/>  - name                          pool name (default "system")<br/>  - vm_size                       VM SKU (default "Standard_D2s_v5")<br/>  - node_count                    node count, or initial count when autoscaling (default 2)<br/>  - min_count / max_count         set both to enable the cluster autoscaler<br/>  - os_disk_size_gb               OS disk size in GB (default 64)<br/>  - only_critical_addons_enabled  taint the pool so only critical add-ons schedule (default false) | <pre>object({<br/>    name                         = optional(string, "system")<br/>    vm_size                      = optional(string, "Standard_D2s_v5")<br/>    node_count                   = optional(number, 2)<br/>    min_count                    = optional(number)<br/>    max_count                    = optional(number)<br/>    os_disk_size_gb              = optional(number, 64)<br/>    only_critical_addons_enabled = optional(bool, false)<br/>  })</pre> | `{}` | no |
| <a name="input_default_node_pool_subnet_id"></a> [default_node_pool_subnet_id](#input_default_node_pool_subnet_id) | Resource ID of the subnet the default node pool runs in (Azure CNI). Compose this from the networking module. | `string` | n/a | yes |
| <a name="input_dns_prefix"></a> [dns_prefix](#input_dns_prefix) | DNS prefix for the cluster's API server. 1 to 54 characters, letters/digits/hyphens, starting and ending with a letter or digit. | `string` | n/a | yes |
| <a name="input_dns_service_ip"></a> [dns_service_ip](#input_dns_service_ip) | IP address for the cluster DNS service. Must be within service_cidr. | `string` | `"10.100.0.10"` | no |
| <a name="input_kubernetes_version"></a> [kubernetes_version](#input_kubernetes_version) | Kubernetes version. Null uses the AKS default for the region. | `string` | `null` | no |
| <a name="input_local_account_disabled"></a> [local_account_disabled](#input_local_account_disabled) | Disable local Kubernetes accounts, forcing all access through Entra. | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input_location) | Azure region for the cluster, for example "eastus2". | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log_analytics_workspace_id](#input_log_analytics_workspace_id) | If set, enables the OMS agent (Container Insights) sending to this Log Analytics workspace. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input_name) | Name of the AKS cluster. 1 to 63 characters, letters/digits/hyphens/underscores, starting and ending with a letter or digit. | `string` | n/a | yes |
| <a name="input_network_policy"></a> [network_policy](#input_network_policy) | Network policy engine: "calico" (default) or "azure". | `string` | `"calico"` | no |
| <a name="input_oidc_issuer_enabled"></a> [oidc_issuer_enabled](#input_oidc_issuer_enabled) | Enable the OIDC issuer (required for workload identity federation). | `bool` | `true` | no |
| <a name="input_private_cluster_enabled"></a> [private_cluster_enabled](#input_private_cluster_enabled) | Deploy a private cluster (API server reachable only from the cluster's virtual network). | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name) | Name of the existing resource group the cluster is created in. | `string` | n/a | yes |
| <a name="input_service_cidr"></a> [service_cidr](#input_service_cidr) | CIDR for Kubernetes service IPs. Must not overlap the node subnet. | `string` | `"10.100.0.0/16"` | no |
| <a name="input_tags"></a> [tags](#input_tags) | Tags applied to the cluster. | `map(string)` | `{}` | no |
| <a name="input_tenant_id"></a> [tenant_id](#input_tenant_id) | Entra tenant ID for cluster RBAC, typically data.azurerm_client_config.current.tenant_id. | `string` | n/a | yes |
| <a name="input_workload_identity_enabled"></a> [workload_identity_enabled](#input_workload_identity_enabled) | Enable Entra Workload Identity on the cluster. | `bool` | `true` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_id"></a> [id](#output_id) | Resource ID of the AKS cluster. |
| <a name="output_identity_principal_id"></a> [identity_principal_id](#output_identity_principal_id) | Principal ID of the cluster's system-assigned managed identity. |
| <a name="output_kubelet_identity_object_id"></a> [kubelet_identity_object_id](#output_kubelet_identity_object_id) | Object ID of the kubelet managed identity (used for ACR pull role assignments, etc.). |
| <a name="output_name"></a> [name](#output_name) | Name of the AKS cluster. |
| <a name="output_node_resource_group"></a> [node_resource_group](#output_node_resource_group) | Name of the auto-generated resource group holding the cluster's node resources. |
| <a name="output_oidc_issuer_url"></a> [oidc_issuer_url](#output_oidc_issuer_url) | OIDC issuer URL, used to configure federated credentials for workload identity. |
<!-- END_TF_DOCS -->
