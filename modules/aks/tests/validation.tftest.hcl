# Input-validation tests. Each run supplies one invalid value and asserts the
# matching variable validation rejects it.

mock_provider "azurerm" {}

variables {
  name                        = "aks-test-eus2-001"
  resource_group_name         = "rg-test"
  location                    = "eastus2"
  dns_prefix                  = "akstest"
  tenant_id                   = "00000000-0000-0000-0000-000000000000"
  default_node_pool_subnet_id = "/subscriptions/x/resourceGroups/y/providers/Microsoft.Network/virtualNetworks/v/subnets/nodes"
}

run "rejects_dns_prefix_with_leading_hyphen" {
  command = plan

  variables {
    dns_prefix = "-bad"
  }

  expect_failures = [var.dns_prefix]
}

run "rejects_unsupported_network_policy" {
  command = plan

  variables {
    network_policy = "cilium"
  }

  expect_failures = [var.network_policy]
}

run "rejects_invalid_service_cidr" {
  command = plan

  variables {
    service_cidr = "not-a-cidr"
  }

  expect_failures = [var.service_cidr]
}

run "rejects_zero_node_count" {
  command = plan

  variables {
    default_node_pool = {
      node_count = 0
    }
  }

  expect_failures = [var.default_node_pool]
}

run "rejects_only_min_count_set" {
  command = plan

  variables {
    default_node_pool = {
      min_count = 2
    }
  }

  expect_failures = [var.default_node_pool]
}

run "rejects_max_count_below_min_count" {
  command = plan

  variables {
    default_node_pool = {
      min_count = 5
      max_count = 2
    }
  }

  expect_failures = [var.default_node_pool]
}
