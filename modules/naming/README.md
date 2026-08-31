# naming

Deterministic Azure resource **naming** and **tagging**.

Given a workload, environment, region and instance number, the module returns a
map of ready-to-use resource names that follow a single documented convention,
plus a merged tag map. It declares no providers and calls no APIs, so it is pure,
fast, and testable without credentials.

## Usage

```hcl
module "naming" {
  source = "github.com/jmsalvo/terraform-azure-modules//modules/naming?ref=v0.1.0"

  workload    = "shop"
  environment = "prod"
  location    = "eastus2"

  tags = {
    application = "storefront"
  }
}

resource "azurerm_resource_group" "this" {
  name     = module.naming.names["resource_group"]
  location = "eastus2"
  tags     = module.naming.tags
}
```

## Naming convention

Dash-style names are built as:

```
<abbr>-<workload>-<environment>-<region>-<instance>[-<suffix>...]
```

For example `rg-shop-prod-eus2-001`. `region` is the abbreviation from the
built-in table (`eastus2` becomes `eus2`); an unmapped region is reduced to its
alphanumerics and used as-is. `instance` is zero-padded to three digits.

Resource types with stricter rules get adjusted names:

| Type | Rule | Form |
|------|------|------|
| `storage_account` | 3-24 chars, lowercase alphanumeric | `st` + compact stem, truncated to 24 |
| `key_vault` | 3-24 chars, alphanumeric and dashes | `kv-` + stem, truncated to 24 |
| `container_registry` | 5-50 chars, alphanumeric | `cr` + compact stem, truncated to 50 |

## Tags

`tags` output = baseline tags (`environment`, `workload`, `managed_by=terraform`,
plus `cost_center` / `owner` when set) merged with the caller's `tags`. On a key
collision the caller's value wins.

## Tests

```bash
terraform -chdir=modules/naming test
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.6.0 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cost_center"></a> [cost_center](#input_cost_center) | Optional cost center identifier; added to the baseline tags as cost_center when set. | `string` | `null` | no |
| <a name="input_environment"></a> [environment](#input_environment) | Deployment environment; one of dev, test, stage, prod, sandbox. | `string` | n/a | yes |
| <a name="input_instance"></a> [instance](#input_instance) | Instance number for the resource set; rendered zero-padded to three digits. | `number` | `1` | no |
| <a name="input_location"></a> [location](#input_location) | Azure region in Azure CLI short form, for example eastus2. Mapped to an abbreviation in names; unmapped values are stripped to alphanumerics and used as-is. | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input_owner) | Optional owner identifier such as a team name or email; added to the baseline tags as owner when set. | `string` | `null` | no |
| <a name="input_suffix"></a> [suffix](#input_suffix) | Additional lowercase alphanumeric tokens appended to every generated name, in order. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input_tags) | Tags supplied by the caller; merged over the module baseline tags, with the caller winning on key collisions. | `map(string)` | `{}` | no |
| <a name="input_workload"></a> [workload](#input_workload) | Short name of the application or workload; lowercase alphanumeric, 2 to 10 characters. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_key_vault_name"></a> [key_vault_name](#output_key_vault_name) | Convenience accessor for names["key_vault"]. |
| <a name="output_name_prefix"></a> [name_prefix](#output_name_prefix) | The dash-joined name stem shared by every generated name, for example shop-prod-eus2-001. |
| <a name="output_names"></a> [names](#output_names) | Map of resource type to generated name. Dash-style for most types; compact and length-limited for storage_account, key_vault and container_registry. |
| <a name="output_resource_group_name"></a> [resource_group_name](#output_resource_group_name) | Convenience accessor for names["resource_group"]. |
| <a name="output_storage_account_name"></a> [storage_account_name](#output_storage_account_name) | Convenience accessor for names["storage_account"]. |
| <a name="output_tags"></a> [tags](#output_tags) | Baseline tags merged with the caller tags; the caller wins on key collisions. |
<!-- END_TF_DOCS -->
