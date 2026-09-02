# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
Versioning is **repo-wide**: one tag covers every module. See
[ADR 0001](docs/decisions/0001-repo-wide-versioning.md).

## [Unreleased]

## [0.1.0] - 2026-09-01

### Added
- Repository scaffold: layout conventions, credential-free CI (`fmt`, `validate`,
  `tflint`, `terraform test`, `trivy config`, `terraform-docs` drift check) and a
  single Terratest example.
- `naming` module — deterministic Azure resource naming and tagging with no
  provider and no API calls; `.tftest.hcl` behaviour and input-validation suites.
- `networking` module — virtual network, subnets, and optional per-subnet NSGs
  (module-created from `security_rules`, or an externally managed NSG by id).
  Decoupled from `naming` (plain name inputs). Tests use `mock_provider "azurerm"`.
- `key-vault` module — RBAC-authorized Key Vault with secure defaults (purge
  protection on, public network access off, network default-deny) and an
  optional diagnostic setting. Callers assign their own RBAC roles.
- `aks` module — hardened AKS cluster: Entra RBAC, `local_account_disabled`,
  private API server, OIDC issuer + workload identity, Azure Policy add-on,
  system-assigned identity, Azure CNI + network policy. Optional autoscaling
  and Container Insights.

### Fixed
- `key-vault` — renamed `enable_rbac_authorization` to `rbac_authorization_enabled`
  ahead of its removal in azurerm v5.0. Swept `naming`, `networking`, and `aks`
  for the same class of deprecation warning under Terraform 1.16 / azurerm
  latest; none found.
