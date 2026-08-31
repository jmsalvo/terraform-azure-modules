# Example: basic

Minimal use of the `naming` module: required inputs plus a couple of caller tags
and a cost center.

```bash
terraform init
terraform plan
```

This example creates no Azure resources — the module only computes strings — so it
needs no credentials and nothing to tear down.

Run it as a test from the repo root:

```bash
cd test && go test -run TestNamingBasicExample -v
```
