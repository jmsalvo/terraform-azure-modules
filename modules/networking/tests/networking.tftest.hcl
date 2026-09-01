# Behaviour tests for the networking module.
# mock_provider means no Azure credentials and no API calls:
#   terraform -chdir=modules/networking test

mock_provider "azurerm" {}

variables {
  resource_group_name = "rg-test"
  location            = "eastus2"
  vnet_name           = "vnet-test"
  address_space       = ["10.0.0.0/16"]
}

run "vnet_uses_the_given_name_and_address_space" {
  command = plan

  assert {
    condition     = azurerm_virtual_network.this.name == "vnet-test"
    error_message = "vnet name did not match input"
  }

  assert {
    condition     = tolist(azurerm_virtual_network.this.address_space) == tolist(["10.0.0.0/16"])
    error_message = "vnet address_space did not match input"
  }
}

run "creates_one_subnet_per_map_entry" {
  command = plan

  variables {
    subnets = {
      app  = { address_prefixes = ["10.0.1.0/24"] }
      data = { address_prefixes = ["10.0.2.0/24"], service_endpoints = ["Microsoft.KeyVault"] }
    }
  }

  assert {
    condition     = length(azurerm_subnet.this) == 2
    error_message = "expected one subnet per map entry"
  }

  assert {
    condition     = tolist(azurerm_subnet.this["app"].address_prefixes) == tolist(["10.0.1.0/24"])
    error_message = "app subnet address prefix is wrong"
  }

  assert {
    condition     = tolist(azurerm_subnet.this["data"].service_endpoints) == tolist(["Microsoft.KeyVault"])
    error_message = "data subnet service endpoints are wrong"
  }
}

run "creates_an_nsg_only_for_subnets_with_rules" {
  command = plan

  variables {
    subnets = {
      app = {
        address_prefixes = ["10.0.1.0/24"]
        security_rules = [{
          name                       = "allow-https-in"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_address_prefix      = "*"
          destination_port_range     = "443"
          destination_address_prefix = "*"
        }]
      }
      data = { address_prefixes = ["10.0.2.0/24"] }
    }
  }

  assert {
    condition     = length(azurerm_network_security_group.this) == 1
    error_message = "only the subnet declaring security_rules should get an NSG"
  }

  assert {
    condition     = contains(keys(azurerm_network_security_group.this), "app")
    error_message = "the app subnet should have a module-managed NSG"
  }

  assert {
    condition     = azurerm_network_security_group.this["app"].name == "nsg-app"
    error_message = "default NSG name should be nsg-<subnet>"
  }

  assert {
    condition     = length(azurerm_subnet_network_security_group_association.this) == 1
    error_message = "exactly one NSG association expected"
  }
}

run "custom_nsg_name_is_honoured" {
  command = plan

  variables {
    subnets = {
      app = {
        address_prefixes = ["10.0.1.0/24"]
        nsg_name         = "nsg-shop-prod-app"
        security_rules = [{
          name                       = "deny-all-in"
          priority                   = 4096
          direction                  = "Inbound"
          access                     = "Deny"
          protocol                   = "*"
          source_address_prefix      = "*"
          destination_port_range     = "*"
          destination_address_prefix = "*"
        }]
      }
    }
  }

  assert {
    condition     = azurerm_network_security_group.this["app"].name == "nsg-shop-prod-app"
    error_message = "nsg_name override was not used"
  }
}

run "external_nsg_is_associated_without_creating_one" {
  command = plan

  variables {
    subnets = {
      app = {
        address_prefixes          = ["10.0.1.0/24"]
        network_security_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/networkSecurityGroups/nsg-external"
      }
    }
  }

  assert {
    condition     = length(azurerm_network_security_group.this) == 0
    error_message = "no NSG should be created when an external id is supplied"
  }

  assert {
    condition     = azurerm_subnet_network_security_group_association.this["app"].network_security_group_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/networkSecurityGroups/nsg-external"
    error_message = "association should point at the external NSG id"
  }
}

run "subnets_without_nsg_config_get_no_association" {
  command = plan

  variables {
    subnets = {
      app = { address_prefixes = ["10.0.1.0/24"] }
    }
  }

  assert {
    condition     = length(azurerm_subnet_network_security_group_association.this) == 0
    error_message = "a plain subnet should get no NSG association"
  }
}

run "tags_propagate_to_vnet_and_managed_nsg" {
  command = plan

  variables {
    tags = { environment = "test", managed_by = "terraform" }
    subnets = {
      app = {
        address_prefixes = ["10.0.1.0/24"]
        security_rules = [{
          name                       = "allow-app-in"
          priority                   = 200
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_address_prefix      = "10.0.0.0/8"
          destination_port_range     = "8080"
          destination_address_prefix = "*"
        }]
      }
    }
  }

  assert {
    condition     = azurerm_virtual_network.this.tags["environment"] == "test"
    error_message = "tags did not propagate to the vnet"
  }

  assert {
    condition     = azurerm_network_security_group.this["app"].tags["managed_by"] == "terraform"
    error_message = "tags did not propagate to the managed NSG"
  }
}
