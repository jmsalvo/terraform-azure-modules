variable "name" {
  description = "Name of the key vault. 3 to 24 characters, letters/digits/hyphens, must start with a letter and not end with a hyphen."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{1,22}[a-zA-Z0-9]$", var.name))
    error_message = "name must be 3 to 24 characters, start with a letter, use only letters/digits/hyphens, and not end with a hyphen."
  }
}

variable "resource_group_name" {
  description = "Name of the existing resource group the key vault is created in."
  type        = string
}

variable "location" {
  description = "Azure region for the key vault, for example \"eastus2\"."
  type        = string
}

variable "tenant_id" {
  description = "Entra tenant ID the key vault is associated with, typically data.azurerm_client_config.current.tenant_id."
  type        = string
}

variable "sku_name" {
  description = "Key vault SKU: \"standard\" or \"premium\" (premium is HSM-backed)."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "sku_name must be \"standard\" or \"premium\"."
  }
}

variable "purge_protection_enabled" {
  description = "Enable purge protection. Cannot be disabled once on; the vault and its contents cannot be permanently deleted until the retention period elapses."
  type        = bool
  default     = true
}

variable "soft_delete_retention_days" {
  description = "Days soft-deleted vault contents are retained before permanent deletion. 7 to 90."
  type        = number
  default     = 90

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "soft_delete_retention_days must be between 7 and 90."
  }
}

variable "public_network_access_enabled" {
  description = "Allow traffic from public networks, still subject to network_acls. Default false: reach the vault via a private endpoint or an explicit allow rule."
  type        = bool
  default     = false
}

variable "network_acls" {
  description = <<-EOT
    Network rules for the vault:
      - default_action              "Deny" (default) or "Allow"
      - bypass                      "AzureServices" (default) or "None"
      - ip_rules                    CIDR ranges allowed to reach the vault
      - virtual_network_subnet_ids  subnet IDs allowed to reach the vault
  EOT

  type = object({
    default_action             = optional(string, "Deny")
    bypass                     = optional(string, "AzureServices")
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default = {}

  validation {
    condition     = contains(["Allow", "Deny"], var.network_acls.default_action)
    error_message = "network_acls.default_action must be \"Allow\" or \"Deny\"."
  }

  validation {
    condition     = contains(["AzureServices", "None"], var.network_acls.bypass)
    error_message = "network_acls.bypass must be \"AzureServices\" or \"None\"."
  }
}

variable "enabled_for_deployment" {
  description = "Allow Azure Virtual Machines to retrieve certificates stored as secrets from the vault."
  type        = bool
  default     = false
}

variable "enabled_for_disk_encryption" {
  description = "Allow Azure Disk Encryption to retrieve secrets and unwrap keys."
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "Allow Azure Resource Manager to retrieve secrets during template deployment."
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "If set, a diagnostic setting sends AuditEvent logs and AllMetrics to this Log Analytics workspace."
  type        = string
  default     = null
}

variable "diagnostic_setting_name" {
  description = "Name of the diagnostic setting created when log_analytics_workspace_id is set."
  type        = string
  default     = "diag"
}

variable "tags" {
  description = "Tags applied to the key vault."
  type        = map(string)
  default     = {}
}
