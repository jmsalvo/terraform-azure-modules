data "azurerm_client_config" "current" {}

module "aks" {
  source = "../../"

  name                = "aks-shop-prod-eus2-001"
  resource_group_name = "rg-shop-prod-eus2-001"
  location            = "eastus2"
  dns_prefix          = "shop-prod"
  tenant_id           = data.azurerm_client_config.current.tenant_id

  # In a real root module this comes from the networking module, e.g.
  # module.networking.subnet_ids["aks"].
  default_node_pool_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-shop-prod-eus2-001/providers/Microsoft.Network/virtualNetworks/vnet-shop-prod-eus2-001/subnets/aks"

  default_node_pool = {
    min_count = 2
    max_count = 5
  }

  tags = {
    environment = "prod"
    workload    = "shop"
    managed_by  = "terraform"
  }
}
