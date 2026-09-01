# Behaviour tests for the key-vault module.
# mock_provider means no Azure credentials and no API calls:
#   terraform -chdir=modules/key-vault test

mock_provider "azurerm" {}

variables {
  name                = "kv-test-eus2-001"
  resource_group_name = "rg-test"
  location            = "eastus2"
  tenant_id           = "00000000-0000-0000-0000-000000000000"
}

run "uses_rbac_and_secure_defaults" {
  command = plan

  assert {
    condition     = azurerm_key_vault.this.enable_rbac_authorization == true
    error_message = "RBAC authorization must be enabled"
  }

  assert {
    condition     = azurerm_key_vault.this.purge_protection_enabled == true
    error_message = "purge protection should default on"
  }

  assert {
    condition     = azurerm_key_vault.this.public_network_access_enabled == false
    error_message = "public network access should default off"
  }

  assert {
    condition     = azurerm_key_vault.this.soft_delete_retention_days == 90
    error_message = "soft delete retention should default to 90"
  }

  assert {
    condition     = azurerm_key_vault.this.sku_name == "standard"
    error_message = "sku should default to standard"
  }
}

run "network_acls_default_to_deny" {
  command = plan

  assert {
    condition     = azurerm_key_vault.this.network_acls[0].default_action == "Deny"
    error_message = "network_acls default_action should be Deny"
  }

  assert {
    condition     = azurerm_key_vault.this.network_acls[0].bypass == "AzureServices"
    error_message = "network_acls bypass should be AzureServices"
  }
}

run "ip_and_subnet_rules_pass_through" {
  command = plan

  variables {
    network_acls = {
      ip_rules                   = ["203.0.113.0/24"]
      virtual_network_subnet_ids = ["/subscriptions/x/resourceGroups/y/providers/Microsoft.Network/virtualNetworks/v/subnets/s"]
    }
  }

  assert {
    condition     = azurerm_key_vault.this.network_acls[0].ip_rules == toset(["203.0.113.0/24"])
    error_message = "ip_rules were not passed through to the vault"
  }

  assert {
    condition     = azurerm_key_vault.this.network_acls[0].virtual_network_subnet_ids == toset(["/subscriptions/x/resourceGroups/y/providers/Microsoft.Network/virtualNetworks/v/subnets/s"])
    error_message = "virtual_network_subnet_ids were not passed through to the vault"
  }
}

run "no_diagnostic_setting_by_default" {
  command = plan

  assert {
    condition     = length(azurerm_monitor_diagnostic_setting.this) == 0
    error_message = "no diagnostic setting should be created without a workspace id"
  }
}

run "diagnostic_setting_created_when_workspace_given" {
  command = plan

  variables {
    log_analytics_workspace_id = "/subscriptions/x/resourceGroups/y/providers/Microsoft.OperationalInsights/workspaces/law"
  }

  assert {
    condition     = length(azurerm_monitor_diagnostic_setting.this) == 1
    error_message = "a diagnostic setting should be created when a workspace id is provided"
  }

  assert {
    condition     = azurerm_monitor_diagnostic_setting.this[0].log_analytics_workspace_id == "/subscriptions/x/resourceGroups/y/providers/Microsoft.OperationalInsights/workspaces/law"
    error_message = "the diagnostic setting should target the given workspace"
  }
}

run "premium_sku_and_tags_pass_through" {
  command = plan

  variables {
    sku_name = "premium"
    tags     = { environment = "test", managed_by = "terraform" }
  }

  assert {
    condition     = azurerm_key_vault.this.sku_name == "premium"
    error_message = "premium sku was not applied"
  }

  assert {
    condition     = azurerm_key_vault.this.tags["managed_by"] == "terraform"
    error_message = "tags were not applied to the vault"
  }
}
