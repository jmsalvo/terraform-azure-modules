module "networking" {
  source = "../../"

  resource_group_name = "rg-shop-prod-eus2-001"
  location            = "eastus2"
  vnet_name           = "vnet-shop-prod-eus2-001"
  address_space       = ["10.20.0.0/16"]

  tags = {
    environment = "prod"
    workload    = "shop"
    managed_by  = "terraform"
  }

  subnets = {
    app = {
      address_prefixes  = ["10.20.1.0/24"]
      service_endpoints = ["Microsoft.KeyVault"]
    }

    data = {
      address_prefixes = ["10.20.2.0/24"]

      # Declaring rules makes the module create and associate an NSG for this subnet.
      security_rules = [
        {
          name                       = "allow-sql-from-app"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_address_prefix      = "10.20.1.0/24"
          destination_port_range     = "1433"
          destination_address_prefix = "10.20.2.0/24"
        },
        {
          name                       = "deny-all-inbound"
          priority                   = 4096
          direction                  = "Inbound"
          access                     = "Deny"
          protocol                   = "*"
          source_address_prefix      = "*"
          destination_port_range     = "*"
          destination_address_prefix = "*"
        },
      ]
    }
  }
}
