# Example: basic

A hardened AKS cluster with the module's defaults — private API server, Entra
RBAC, local accounts disabled, workload identity, Azure Policy add-on, Azure CNI
with Calico — plus an autoscaling default node pool (2 to 5 nodes).

```bash
terraform init
terraform validate      # no credentials needed
```

`terraform plan` / `apply` need a real Azure subscription, an authenticated
session, and a real `default_node_pool_subnet_id`. An AKS cluster is a
non-trivial cost — run `terraform destroy` when done.
