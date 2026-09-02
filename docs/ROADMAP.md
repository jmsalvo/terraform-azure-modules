# Roadmap — deferred scope

Every module in this repo shipped a deliberately small `v1` (tagged `v0.1.0`). This
is the deferred scope, per module, roughly in priority order. Nothing here is
required by the consuming `secure-azure-platform` flagship — it consumes `v1` as
shipped, and any item below can be pulled forward if a milestone needs it.

## Cross-cutting

- **A `complete/` example per module** alongside `basic/` (exercises every input).
- **One real end-to-end Terratest per module**, gated behind a CI label + Entra OIDC
  (federated, no stored secret). Deliberately deferred — CI is credential-free today.
- **`checkov` alongside `trivy`**, and/or **Conftest/OPA** policies for org-specific
  rules (naming, required tags, allowed regions) gating the plan.
- **Renovate or Dependabot** for the pinned versions (azurerm, GitHub Actions, tflint
  ruleset, terraform-docs).
- **Per-module versioning / registry publishing** — see [ADR 0001](decisions/0001-repo-wide-versioning.md).
- Repo hygiene: `CODEOWNERS`, PR/issue templates, `SECURITY.md`.
- **`sku_tier` / cost knobs** surfaced consistently where they exist (AKS Free vs
  Standard SLA, etc.).

## naming

- Expand the CAF abbreviation map (~13 types now → the full ~100) and the region
  map (15 now).
- **Optional random suffix** for globally-unique resources (storage, ACR, Key
  Vault) — today names are fully deterministic, so two environments with
  identical inputs collide.
- Emit a `names_valid` check / `precondition`s validating each generated name
  against Azure's real per-type length/charset rules.
- Per-entry overrides — let a caller replace one key in the `names` map.
- Configurable separator (dash / none) instead of hardcoded.

## networking

- **Route tables / UDR** (forced tunneling, NVA next-hop).
- **NAT gateway** association per subnet.
- **VNet peering** (hub/spoke) inputs.
- **Private DNS zones** + virtual-network links.
- Subnet `private_endpoint_network_policies` / `private_link_service_network_policies`
  toggles (dropped from v1 to contain scope).
- `service_delegation.actions` list (v1 sets only `name`).
- DDoS protection plan association; NSG flow logs / diagnostic settings.
- IPv6 / dual-stack address space.

## key-vault

- **Private endpoint** + private DNS integration.
- Optional `role_assignments` map for convenience (v1: caller does every
  assignment).
- Diagnostic setting: configurable log categories / category groups (add
  `AzurePolicyEvaluationDetails`), not just `AuditEvent`.
- Certificate `contact`s and key auto-rotation policy.
- CMK / infrastructure-encryption toggle.
- (Explicitly **not** planned: access-policy auth mode — RBAC only, by design.)

## aks

- **Additional node pools** (`azurerm_kubernetes_cluster_node_pool` — user /
  spot / GPU).
- **API server authorized IP ranges** (for the non-private-cluster case).
- **Maintenance windows** (`maintenance_window`, `maintenance_window_auto_upgrade`).
- **Microsoft Defender for Containers** block.
- **Automatic upgrade channels** (cluster + node-OS).
- **Control-plane diagnostic settings** (`kube-apiserver`, `kube-audit`,
  `kube-audit-admin`, `kube-controller-manager`, `cluster-autoscaler`, ...).
- **Azure CNI Overlay** (`network_plugin_mode = "overlay"`) and **Cilium data
  plane** (`network_data_plane = "cilium"`) — v1 is plain Azure CNI + Calico.
- Add-ons: **Key Vault Secrets Provider (CSI)**, KEDA / VPA workload autoscaler.
- User-assigned cluster identity / BYO kubelet identity.
- BYO private DNS zone for the private cluster.
- `sku_tier` (Free → Standard for the uptime SLA); `node_resource_group` name
  control.
