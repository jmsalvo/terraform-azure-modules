locals {
  node_pool_autoscaling = var.default_node_pool.min_count != null
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  private_cluster_enabled   = var.private_cluster_enabled
  local_account_disabled    = var.local_account_disabled
  oidc_issuer_enabled       = var.oidc_issuer_enabled
  workload_identity_enabled = var.workload_identity_enabled
  azure_policy_enabled      = var.azure_policy_enabled

  identity {
    type = "SystemAssigned"
  }

  azure_active_directory_role_based_access_control {
    tenant_id              = var.tenant_id
    azure_rbac_enabled     = true
    admin_group_object_ids = var.admin_group_object_ids
  }

  default_node_pool {
    name                         = var.default_node_pool.name
    vm_size                      = var.default_node_pool.vm_size
    vnet_subnet_id               = var.default_node_pool_subnet_id
    os_disk_size_gb              = var.default_node_pool.os_disk_size_gb
    only_critical_addons_enabled = var.default_node_pool.only_critical_addons_enabled

    auto_scaling_enabled = local.node_pool_autoscaling
    node_count           = var.default_node_pool.node_count
    min_count            = var.default_node_pool.min_count
    max_count            = var.default_node_pool.max_count
  }

  network_profile {
    network_plugin = "azure"
    network_policy = var.network_policy
    service_cidr   = var.service_cidr
    dns_service_ip = var.dns_service_ip
  }

  dynamic "oms_agent" {
    for_each = var.log_analytics_workspace_id == null ? [] : [var.log_analytics_workspace_id]
    content {
      log_analytics_workspace_id = oms_agent.value
    }
  }

  tags = var.tags
}
