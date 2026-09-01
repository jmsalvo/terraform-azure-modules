# Input-validation tests. Each run supplies one invalid value and asserts the
# matching variable validation rejects it.

mock_provider "azurerm" {}

variables {
  resource_group_name = "rg-test"
  location            = "eastus2"
  vnet_name           = "vnet-test"
  address_space       = ["10.0.0.0/16"]
}

run "rejects_empty_address_space" {
  command = plan

  variables {
    address_space = []
  }

  expect_failures = [var.address_space]
}

run "rejects_invalid_cidr_in_address_space" {
  command = plan

  variables {
    address_space = ["10.0.0.0/16", "not-a-cidr"]
  }

  expect_failures = [var.address_space]
}

run "rejects_subnet_with_no_address_prefixes" {
  command = plan

  variables {
    subnets = {
      app = { address_prefixes = [] }
    }
  }

  expect_failures = [var.subnets]
}

run "rejects_subnet_with_both_rules_and_external_nsg" {
  command = plan

  variables {
    subnets = {
      app = {
        address_prefixes          = ["10.0.1.0/24"]
        network_security_group_id = "/subscriptions/x/resourceGroups/y/providers/Microsoft.Network/networkSecurityGroups/z"
        security_rules = [{
          name                       = "r"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_address_prefix      = "*"
          destination_port_range     = "443"
          destination_address_prefix = "*"
        }]
      }
    }
  }

  expect_failures = [var.subnets]
}

run "rejects_bad_security_rule_direction" {
  command = plan

  variables {
    subnets = {
      app = {
        address_prefixes = ["10.0.1.0/24"]
        security_rules = [{
          name                       = "bad-direction"
          priority                   = 100
          direction                  = "Sideways"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_address_prefix      = "*"
          destination_port_range     = "443"
          destination_address_prefix = "*"
        }]
      }
    }
  }

  expect_failures = [var.subnets]
}

run "rejects_bad_security_rule_access" {
  command = plan

  variables {
    subnets = {
      app = {
        address_prefixes = ["10.0.1.0/24"]
        security_rules = [{
          name                       = "bad-access"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Maybe"
          protocol                   = "Tcp"
          source_address_prefix      = "*"
          destination_port_range     = "443"
          destination_address_prefix = "*"
        }]
      }
    }
  }

  expect_failures = [var.subnets]
}
