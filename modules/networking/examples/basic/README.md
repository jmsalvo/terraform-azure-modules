# Example: basic

A virtual network with two subnets: `app` (with a service endpoint) and `data`
(with a module-managed NSG built from `security_rules`).

```bash
terraform init
terraform validate      # no credentials needed
```

`terraform plan` / `apply` need a real Azure subscription — set `ARM_SUBSCRIPTION_ID`
(or edit `versions.tf`) and authenticate first. This example creates real
resources; run `terraform destroy` when done.
