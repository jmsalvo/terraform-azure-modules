# networking

An Azure **virtual network** with **subnets** and **optional per-subnet NSGs**.

Scope is deliberately small: VNet + subnets + NSGs. Route tables, NAT gateways,
VNet peering, and private DNS zone links are out of scope for now — they belong
in later versions or their own modules.

## Usage

```hcl
module "naming" {
  source      = "github.com/jmsalvo/terraform-azure-modules//modules/naming?ref=v0.1.0"
  workload    = "shop"
  environment = "prod"
  location    = "eastus2"
}

module "networking" {
  source = "github.com/jmsalvo/terraform-azure-modules//modules/networking?ref=v0.1.0"

  resource_group_name = "rg-shop-prod-eus2-001"
  location            = "eastus2"
  vnet_name           = module.naming.names["virtual_network"]
  address_space       = ["10.20.0.0/16"]
  tags                = module.naming.tags

  subnets = {
    app  = { address_prefixes = ["10.20.1.0/24"], service_endpoints = ["Microsoft.KeyVault"] }
    data = {
      address_prefixes = ["10.20.2.0/24"]
      security_rules = [{
        name                       = "allow-sql-from-app"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_address_prefix      = "10.20.1.0/24"
        destination_port_range     = "1433"
        destination_address_prefix = "10.20.2.0/24"
      }]
    }
  }
}
```

The module takes plain `vnet_name` / `tags` values — it does **not** call the
`naming` module. Compose them in the root module, as above.

## NSG behaviour

Per subnet, exactly one of:

- **`security_rules` set** → the module creates an NSG (`nsg-<subnet>`, or
  `nsg_name` if given), adds the rules, and associates it with the subnet.
- **`network_security_group_id` set** → the module associates that externally
  managed NSG and creates nothing.
- **neither** → the subnet has no NSG association.

Setting both `security_rules` and `network_security_group_id` on one subnet is a
validation error.

## Tests

```bash
terraform -chdir=modules/networking test
```

Tests use `mock_provider "azurerm"`, so they need no Azure credentials.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.6.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider_azurerm) | ~> 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_network_security_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_address_space"></a> [address_space](#input_address_space) | Address space of the virtual network, as a list of CIDR blocks. | `list(string)` | n/a | yes |
| <a name="input_dns_servers"></a> [dns_servers](#input_dns_servers) | Custom DNS servers for the virtual network. Empty list uses Azure-provided DNS. | `list(string)` | `[]` | no |
| <a name="input_location"></a> [location](#input_location) | Azure region for all resources in this module, for example "eastus2". | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name) | Name of the existing resource group the network resources are created in. | `string` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input_subnets) | Subnets to create, keyed by subnet name. Per subnet:<br/>  - address_prefixes           (required) list of CIDR blocks<br/>  - service_endpoints          optional list of service endpoint names, e.g. "Microsoft.KeyVault"<br/>  - delegation                 optional { name, service_delegation_name } for subnet delegation<br/>  - nsg_name                   optional name for the module-created NSG (default "nsg-<subnet>")<br/>  - security_rules             optional list of NSG rules; when non-empty the module creates<br/>                               an NSG for the subnet, adds the rules, and associates it<br/>  - network_security_group_id  optional id of an externally managed NSG to associate instead;<br/>                               mutually exclusive with security_rules | <pre>map(object({<br/>    address_prefixes  = list(string)<br/>    service_endpoints = optional(list(string), [])<br/>    delegation = optional(object({<br/>      name                    = string<br/>      service_delegation_name = string<br/>    }))<br/>    nsg_name                  = optional(string)<br/>    network_security_group_id = optional(string)<br/>    security_rules = optional(list(object({<br/>      name                         = string<br/>      priority                     = number<br/>      direction                    = string<br/>      access                       = string<br/>      protocol                     = string<br/>      source_port_range            = optional(string)<br/>      source_port_ranges           = optional(list(string))<br/>      destination_port_range       = optional(string)<br/>      destination_port_ranges      = optional(list(string))<br/>      source_address_prefix        = optional(string)<br/>      source_address_prefixes      = optional(list(string))<br/>      destination_address_prefix   = optional(string)<br/>      destination_address_prefixes = optional(list(string))<br/>    })), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input_tags) | Tags applied to every resource this module creates. | `map(string)` | `{}` | no |
| <a name="input_vnet_name"></a> [vnet_name](#input_vnet_name) | Name of the virtual network. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_network_security_group_ids"></a> [network_security_group_ids](#output_network_security_group_ids) | Map of subnet name to associated NSG ID (module-created or caller-supplied). Subnets with no NSG are absent. |
| <a name="output_subnet_address_prefixes"></a> [subnet_address_prefixes](#output_subnet_address_prefixes) | Map of subnet name to its address prefixes. |
| <a name="output_subnet_ids"></a> [subnet_ids](#output_subnet_ids) | Map of subnet name to subnet resource ID. |
| <a name="output_vnet_address_space"></a> [vnet_address_space](#output_vnet_address_space) | Address space of the virtual network. |
| <a name="output_vnet_id"></a> [vnet_id](#output_vnet_id) | Resource ID of the virtual network. |
| <a name="output_vnet_name"></a> [vnet_name](#output_vnet_name) | Name of the virtual network. |
<!-- END_TF_DOCS -->
