# Example: basic

An RBAC-authorized key vault with the module's secure defaults (purge protection
on, public network access off, network default-deny) plus one allowed IP range.

```bash
terraform init
terraform validate      # no credentials needed
```

`terraform plan` / `apply` need a real Azure subscription and an authenticated
session (the `tenant_id` comes from `azurerm_client_config`). This example
creates a real key vault; run `terraform destroy` when done. Note that with
purge protection enabled the vault name cannot be reused until the soft-delete
retention period elapses.
