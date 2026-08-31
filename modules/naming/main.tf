locals {
  # Common Azure region short codes. Unmapped regions fall back to the raw
  # value with any non-alphanumeric characters removed.
  region_abbreviations = {
    australiaeast = "aue"
    canadacentral = "cac"
    centralindia  = "inc"
    centralus     = "cus"
    eastasia      = "ea"
    eastus        = "eus"
    eastus2       = "eus2"
    northeurope   = "neu"
    southeastasia = "sea"
    uksouth       = "uks"
    ukwest        = "ukw"
    westeurope    = "weu"
    westus        = "wus"
    westus2       = "wus2"
    westus3       = "wus3"
  }

  region         = lookup(local.region_abbreviations, var.location, replace(var.location, "/[^a-z0-9]/", ""))
  instance_token = format("%03d", var.instance)

  # Ordered tokens shared by every generated name.
  base_tokens = concat(
    [var.workload, var.environment, local.region, local.instance_token],
    var.suffix,
  )

  # Dash-joined stem, for example "shop-prod-eus2-001".
  name_prefix = join("-", local.base_tokens)

  # Compact, lowercase-alphanumeric stem for resources that forbid dashes.
  name_compact = lower(join("", local.base_tokens))

  # CAF-style resource type abbreviations. Subset for now; extended as modules
  # are added. https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations
  abbreviations = {
    container_registry      = "cr"
    key_vault               = "kv"
    kubernetes_cluster      = "aks"
    load_balancer           = "lb"
    log_analytics_workspace = "log"
    network_security_group  = "nsg"
    public_ip               = "pip"
    resource_group          = "rg"
    route_table             = "rt"
    storage_account         = "st"
    subnet                  = "snet"
    user_assigned_identity  = "id"
    virtual_network         = "vnet"
  }

  # Dash-style names for every known resource type.
  dashed_names = {
    for type, abbr in local.abbreviations : type => "${abbr}-${local.name_prefix}"
  }

  # Resources with tight length or character rules get compact, truncated names.
  key_vault_candidate          = "${local.abbreviations.key_vault}-${local.name_prefix}"
  storage_account_candidate    = "${local.abbreviations.storage_account}${local.name_compact}"
  container_registry_candidate = "${local.abbreviations.container_registry}${local.name_compact}"

  # Key Vault: 3-24 chars, alphanumerics and dashes.
  key_vault_name = substr(local.key_vault_candidate, 0, min(24, length(local.key_vault_candidate)))

  # Storage account: 3-24 chars, lowercase alphanumerics only.
  storage_account_name = substr(local.storage_account_candidate, 0, min(24, length(local.storage_account_candidate)))

  # Container registry: 5-50 chars, alphanumerics only.
  container_registry_name = substr(local.container_registry_candidate, 0, min(50, length(local.container_registry_candidate)))

  names = merge(
    local.dashed_names,
    {
      container_registry = local.container_registry_name
      key_vault          = local.key_vault_name
      storage_account    = local.storage_account_name
    },
  )

  # Baseline tags. Entries with a null value are dropped before the merge.
  baseline_tags = {
    for key, value in {
      cost_center = var.cost_center
      environment = var.environment
      managed_by  = "terraform"
      owner       = var.owner
      workload    = var.workload
    } : key => value if value != null
  }

  tags = merge(local.baseline_tags, var.tags)
}
