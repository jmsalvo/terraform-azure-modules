data "azurerm_client_config" "current" {}

module "key_vault" {
  source = "../../"

  name                = "kv-shop-prod-eus2-001"
  resource_group_name = "rg-shop-prod-eus2-001"
  location            = "eastus2"
  tenant_id           = data.azurerm_client_config.current.tenant_id

  # Allow a corporate egress range and a subnet to reach the vault; everything
  # else is denied (the module default).
  network_acls = {
    ip_rules = ["203.0.113.0/24"]
  }

  tags = {
    environment = "prod"
    workload    = "shop"
    managed_by  = "terraform"
  }
}
