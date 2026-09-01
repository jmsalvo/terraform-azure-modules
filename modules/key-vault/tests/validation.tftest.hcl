# Input-validation tests. Each run supplies one invalid value and asserts the
# matching variable validation rejects it.

mock_provider "azurerm" {}

variables {
  name                = "kv-test-eus2-001"
  resource_group_name = "rg-test"
  location            = "eastus2"
  tenant_id           = "00000000-0000-0000-0000-000000000000"
}

run "rejects_short_name" {
  command = plan

  variables {
    name = "kv"
  }

  expect_failures = [var.name]
}

run "rejects_name_with_underscore" {
  command = plan

  variables {
    name = "kv_test"
  }

  expect_failures = [var.name]
}

run "rejects_name_ending_with_hyphen" {
  command = plan

  variables {
    name = "kv-test-"
  }

  expect_failures = [var.name]
}

run "rejects_unknown_sku" {
  command = plan

  variables {
    sku_name = "ultra"
  }

  expect_failures = [var.sku_name]
}

run "rejects_retention_below_seven" {
  command = plan

  variables {
    soft_delete_retention_days = 5
  }

  expect_failures = [var.soft_delete_retention_days]
}

run "rejects_retention_above_ninety" {
  command = plan

  variables {
    soft_delete_retention_days = 120
  }

  expect_failures = [var.soft_delete_retention_days]
}

run "rejects_bad_network_acls_default_action" {
  command = plan

  variables {
    network_acls = {
      default_action = "Block"
    }
  }

  expect_failures = [var.network_acls]
}

run "rejects_bad_network_acls_bypass" {
  command = plan

  variables {
    network_acls = {
      bypass = "Everything"
    }
  }

  expect_failures = [var.network_acls]
}
