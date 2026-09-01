# key-vault

An Azure **Key Vault** with RBAC authorization and secure defaults.

- **RBAC only** — `enable_rbac_authorization = true`. No access-policy support
  (access policies are legacy). The module creates the vault; **callers assign
  their own roles** (e.g. `Key Vault Secrets Officer`) to the principals that
  need access.
- **Secure by default** — purge protection on, 90-day soft-delete retention,
  `public_network_access_enabled = false`, and `network_acls` defaulting to
  `default_action = "Deny"` with `bypass = "AzureServices"`.
- **Optional diagnostics** — set `log_analytics_workspace_id` to ship
  `AuditEvent` logs and `AllMetrics` to a workspace.

## Usage

```hcl
data "azurerm_client_config" "current" {}

module "key_vault" {
  source = "github.com/jmsalvo/terraform-azure-modules//modules/key-vault?ref=v0.1.0"

  name                = "kv-shop-prod-eus2-001"
  resource_group_name = "rg-shop-prod-eus2-001"
  location            = "eastus2"
  tenant_id           = data.azurerm_client_config.current.tenant_id

  network_acls = {
    ip_rules                   = ["203.0.113.0/24"]
    virtual_network_subnet_ids = [module.networking.subnet_ids["app"]]
  }

  log_analytics_workspace_id = module.observability.workspace_id
  tags                       = module.naming.tags
}

resource "azurerm_role_assignment" "secrets_officer" {
  scope                = module.key_vault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = var.deployer_principal_id
}
```

Like the other modules, `key-vault` takes plain values (`name`, `tenant_id`,
`tags`) — compose it with `naming` / `networking` in the root module.

## Reaching the vault

With `public_network_access_enabled = false` and no allow rules, only the
`AzureServices` bypass can reach the vault. Grant access by adding `ip_rules` /
`virtual_network_subnet_ids`, setting `public_network_access_enabled = true`, or
attaching a private endpoint (not part of this module).

## Tests

```bash
terraform -chdir=modules/key-vault test
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
| [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_diagnostic_setting_name"></a> [diagnostic_setting_name](#input_diagnostic_setting_name) | Name of the diagnostic setting created when log_analytics_workspace_id is set. | `string` | `"diag"` | no |
| <a name="input_enabled_for_deployment"></a> [enabled_for_deployment](#input_enabled_for_deployment) | Allow Azure Virtual Machines to retrieve certificates stored as secrets from the vault. | `bool` | `false` | no |
| <a name="input_enabled_for_disk_encryption"></a> [enabled_for_disk_encryption](#input_enabled_for_disk_encryption) | Allow Azure Disk Encryption to retrieve secrets and unwrap keys. | `bool` | `false` | no |
| <a name="input_enabled_for_template_deployment"></a> [enabled_for_template_deployment](#input_enabled_for_template_deployment) | Allow Azure Resource Manager to retrieve secrets during template deployment. | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input_location) | Azure region for the key vault, for example "eastus2". | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log_analytics_workspace_id](#input_log_analytics_workspace_id) | If set, a diagnostic setting sends AuditEvent logs and AllMetrics to this Log Analytics workspace. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input_name) | Name of the key vault. 3 to 24 characters, letters/digits/hyphens, must start with a letter and not end with a hyphen. | `string` | n/a | yes |
| <a name="input_network_acls"></a> [network_acls](#input_network_acls) | Network rules for the vault:<br/>  - default_action              "Deny" (default) or "Allow"<br/>  - bypass                      "AzureServices" (default) or "None"<br/>  - ip_rules                    CIDR ranges allowed to reach the vault<br/>  - virtual_network_subnet_ids  subnet IDs allowed to reach the vault | <pre>object({<br/>    default_action             = optional(string, "Deny")<br/>    bypass                     = optional(string, "AzureServices")<br/>    ip_rules                   = optional(list(string), [])<br/>    virtual_network_subnet_ids = optional(list(string), [])<br/>  })</pre> | `{}` | no |
| <a name="input_public_network_access_enabled"></a> [public_network_access_enabled](#input_public_network_access_enabled) | Allow traffic from public networks, still subject to network_acls. Default false: reach the vault via a private endpoint or an explicit allow rule. | `bool` | `false` | no |
| <a name="input_purge_protection_enabled"></a> [purge_protection_enabled](#input_purge_protection_enabled) | Enable purge protection. Cannot be disabled once on; the vault and its contents cannot be permanently deleted until the retention period elapses. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name) | Name of the existing resource group the key vault is created in. | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku_name](#input_sku_name) | Key vault SKU: "standard" or "premium" (premium is HSM-backed). | `string` | `"standard"` | no |
| <a name="input_soft_delete_retention_days"></a> [soft_delete_retention_days](#input_soft_delete_retention_days) | Days soft-deleted vault contents are retained before permanent deletion. 7 to 90. | `number` | `90` | no |
| <a name="input_tags"></a> [tags](#input_tags) | Tags applied to the key vault. | `map(string)` | `{}` | no |
| <a name="input_tenant_id"></a> [tenant_id](#input_tenant_id) | Entra tenant ID the key vault is associated with, typically data.azurerm_client_config.current.tenant_id. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_id"></a> [id](#output_id) | Resource ID of the key vault. |
| <a name="output_name"></a> [name](#output_name) | Name of the key vault. |
| <a name="output_vault_uri"></a> [vault_uri](#output_vault_uri) | URI of the key vault for client use, https://<name>.vault.azure.net/. |
<!-- END_TF_DOCS -->
