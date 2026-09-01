# Behaviour tests for the aks module.
# mock_provider means no Azure credentials and no API calls:
#   terraform -chdir=modules/aks test

mock_provider "azurerm" {}

variables {
  name                        = "aks-test-eus2-001"
  resource_group_name         = "rg-test"
  location                    = "eastus2"
  dns_prefix                  = "akstest"
  tenant_id                   = "00000000-0000-0000-0000-000000000000"
  default_node_pool_subnet_id = "/subscriptions/x/resourceGroups/y/providers/Microsoft.Network/virtualNetworks/v/subnets/nodes"
}

run "hardening_flags_default_on" {
  command = plan

  assert {
    condition     = azurerm_kubernetes_cluster.this.local_account_disabled == true
    error_message = "local_account_disabled should default on"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.private_cluster_enabled == true
    error_message = "private_cluster_enabled should default on"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.oidc_issuer_enabled == true
    error_message = "oidc_issuer_enabled should default on"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.workload_identity_enabled == true
    error_message = "workload_identity_enabled should default on"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.azure_policy_enabled == true
    error_message = "azure_policy_enabled should default on"
  }
}

run "entra_rbac_is_configured" {
  command = plan

  assert {
    condition     = azurerm_kubernetes_cluster.this.azure_active_directory_role_based_access_control[0].azure_rbac_enabled == true
    error_message = "azure_rbac_enabled should be true"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.azure_active_directory_role_based_access_control[0].tenant_id == "00000000-0000-0000-0000-000000000000"
    error_message = "tenant_id should be passed to the AAD RBAC block"
  }
}

run "uses_system_assigned_identity" {
  command = plan

  assert {
    condition     = azurerm_kubernetes_cluster.this.identity[0].type == "SystemAssigned"
    error_message = "cluster should use a system-assigned identity"
  }
}

run "network_profile_defaults" {
  command = plan

  assert {
    condition     = azurerm_kubernetes_cluster.this.network_profile[0].network_plugin == "azure"
    error_message = "network_plugin should be azure (Azure CNI)"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.network_profile[0].network_policy == "calico"
    error_message = "network_policy should default to calico"
  }
}

run "default_node_pool_no_autoscaling" {
  command = plan

  assert {
    condition     = azurerm_kubernetes_cluster.this.default_node_pool[0].auto_scaling_enabled == false
    error_message = "autoscaling should be off when min/max are not set"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.default_node_pool[0].node_count == 2
    error_message = "node_count should default to 2"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.default_node_pool[0].name == "system"
    error_message = "default node pool name should be system"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.default_node_pool[0].vnet_subnet_id == "/subscriptions/x/resourceGroups/y/providers/Microsoft.Network/virtualNetworks/v/subnets/nodes"
    error_message = "default node pool should use the given subnet id"
  }
}

run "default_node_pool_with_autoscaling" {
  command = plan

  variables {
    default_node_pool = {
      min_count = 2
      max_count = 5
    }
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.default_node_pool[0].auto_scaling_enabled == true
    error_message = "autoscaling should be on when min and max are set"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.default_node_pool[0].min_count == 2 && azurerm_kubernetes_cluster.this.default_node_pool[0].max_count == 5
    error_message = "min/max count should be passed through"
  }
}

run "oms_agent_absent_by_default" {
  command = plan

  assert {
    condition     = length(azurerm_kubernetes_cluster.this.oms_agent) == 0
    error_message = "oms_agent should not be configured without a workspace id"
  }
}

run "oms_agent_present_with_workspace" {
  command = plan

  variables {
    log_analytics_workspace_id = "/subscriptions/x/resourceGroups/y/providers/Microsoft.OperationalInsights/workspaces/law"
  }

  assert {
    condition     = length(azurerm_kubernetes_cluster.this.oms_agent) == 1
    error_message = "oms_agent should be configured when a workspace id is provided"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.oms_agent[0].log_analytics_workspace_id == "/subscriptions/x/resourceGroups/y/providers/Microsoft.OperationalInsights/workspaces/law"
    error_message = "oms_agent should target the given workspace"
  }
}

run "admin_groups_and_tags_pass_through" {
  command = plan

  variables {
    admin_group_object_ids = ["11111111-1111-1111-1111-111111111111"]
    tags                   = { environment = "test", managed_by = "terraform" }
  }

  assert {
    condition     = contains(azurerm_kubernetes_cluster.this.azure_active_directory_role_based_access_control[0].admin_group_object_ids, "11111111-1111-1111-1111-111111111111")
    error_message = "admin_group_object_ids should be passed through"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.tags["managed_by"] == "terraform"
    error_message = "tags should be applied to the cluster"
  }
}
