variable "name" {
  description = "Name of the AKS cluster. 1 to 63 characters, letters/digits/hyphens/underscores, starting and ending with a letter or digit."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_-]{0,61}[a-zA-Z0-9]$", var.name))
    error_message = "name must be 1 to 63 characters and start/end with a letter or digit."
  }
}

variable "resource_group_name" {
  description = "Name of the existing resource group the cluster is created in."
  type        = string
}

variable "location" {
  description = "Azure region for the cluster, for example \"eastus2\"."
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the cluster's API server. 1 to 54 characters, letters/digits/hyphens, starting and ending with a letter or digit."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{0,52}[a-zA-Z0-9]$", var.dns_prefix))
    error_message = "dns_prefix must be 1 to 54 characters and start/end with a letter or digit."
  }
}

variable "tenant_id" {
  description = "Entra tenant ID for cluster RBAC, typically data.azurerm_client_config.current.tenant_id."
  type        = string
}

variable "default_node_pool_subnet_id" {
  description = "Resource ID of the subnet the default node pool runs in (Azure CNI). Compose this from the networking module."
  type        = string
}

variable "admin_group_object_ids" {
  description = "Entra group object IDs granted cluster-admin via Azure RBAC for Kubernetes."
  type        = list(string)
  default     = []
}

variable "kubernetes_version" {
  description = "Kubernetes version. Null uses the AKS default for the region."
  type        = string
  default     = null
}

variable "private_cluster_enabled" {
  description = "Deploy a private cluster (API server reachable only from the cluster's virtual network)."
  type        = bool
  default     = true
}

variable "local_account_disabled" {
  description = "Disable local Kubernetes accounts, forcing all access through Entra."
  type        = bool
  default     = true
}

variable "oidc_issuer_enabled" {
  description = "Enable the OIDC issuer (required for workload identity federation)."
  type        = bool
  default     = true
}

variable "workload_identity_enabled" {
  description = "Enable Entra Workload Identity on the cluster."
  type        = bool
  default     = true
}

variable "azure_policy_enabled" {
  description = "Enable the Azure Policy add-on."
  type        = bool
  default     = true
}

variable "network_policy" {
  description = "Network policy engine: \"calico\" (default) or \"azure\"."
  type        = string
  default     = "calico"

  validation {
    condition     = contains(["calico", "azure"], var.network_policy)
    error_message = "network_policy must be \"calico\" or \"azure\"."
  }
}

variable "service_cidr" {
  description = "CIDR for Kubernetes service IPs. Must not overlap the node subnet."
  type        = string
  default     = "10.100.0.0/16"

  validation {
    condition     = can(cidrhost(var.service_cidr, 0))
    error_message = "service_cidr must be a valid CIDR block."
  }
}

variable "dns_service_ip" {
  description = "IP address for the cluster DNS service. Must be within service_cidr."
  type        = string
  default     = "10.100.0.10"

  validation {
    condition     = can(cidrnetmask("${var.dns_service_ip}/32"))
    error_message = "dns_service_ip must be a valid IP address."
  }
}

variable "default_node_pool" {
  description = <<-EOT
    Default (system) node pool:
      - name                          pool name (default "system")
      - vm_size                       VM SKU (default "Standard_D2s_v5")
      - node_count                    node count, or initial count when autoscaling (default 2)
      - min_count / max_count         set both to enable the cluster autoscaler
      - os_disk_size_gb               OS disk size in GB (default 64)
      - only_critical_addons_enabled  taint the pool so only critical add-ons schedule (default false)
  EOT

  type = object({
    name                         = optional(string, "system")
    vm_size                      = optional(string, "Standard_D2s_v5")
    node_count                   = optional(number, 2)
    min_count                    = optional(number)
    max_count                    = optional(number)
    os_disk_size_gb              = optional(number, 64)
    only_critical_addons_enabled = optional(bool, false)
  })
  default = {}

  validation {
    condition     = var.default_node_pool.node_count >= 1
    error_message = "default_node_pool.node_count must be at least 1."
  }

  validation {
    condition     = (var.default_node_pool.min_count == null) == (var.default_node_pool.max_count == null)
    error_message = "set both default_node_pool.min_count and default_node_pool.max_count to enable autoscaling, or neither."
  }

  validation {
    condition = (
      var.default_node_pool.min_count == null ||
      var.default_node_pool.max_count == null ||
      (var.default_node_pool.min_count >= 1 && var.default_node_pool.max_count >= var.default_node_pool.min_count)
    )
    error_message = "when autoscaling, default_node_pool.min_count must be >= 1 and no greater than max_count."
  }
}

variable "log_analytics_workspace_id" {
  description = "If set, enables the OMS agent (Container Insights) sending to this Log Analytics workspace."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to the cluster."
  type        = map(string)
  default     = {}
}
