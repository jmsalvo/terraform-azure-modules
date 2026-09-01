variable "resource_group_name" {
  description = "Name of the existing resource group the network resources are created in."
  type        = string
}

variable "location" {
  description = "Azure region for all resources in this module, for example \"eastus2\"."
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network."
  type        = string
}

variable "address_space" {
  description = "Address space of the virtual network, as a list of CIDR blocks."
  type        = list(string)

  validation {
    condition     = length(var.address_space) > 0
    error_message = "address_space must contain at least one CIDR block."
  }

  validation {
    condition     = alltrue([for cidr in var.address_space : can(cidrhost(cidr, 0))])
    error_message = "every entry in address_space must be a valid CIDR block."
  }
}

variable "dns_servers" {
  description = "Custom DNS servers for the virtual network. Empty list uses Azure-provided DNS."
  type        = list(string)
  default     = []
}

variable "subnets" {
  description = <<-EOT
    Subnets to create, keyed by subnet name. Per subnet:
      - address_prefixes           (required) list of CIDR blocks
      - service_endpoints          optional list of service endpoint names, e.g. "Microsoft.KeyVault"
      - delegation                 optional { name, service_delegation_name } for subnet delegation
      - nsg_name                   optional name for the module-created NSG (default "nsg-<subnet>")
      - security_rules             optional list of NSG rules; when non-empty the module creates
                                   an NSG for the subnet, adds the rules, and associates it
      - network_security_group_id  optional id of an externally managed NSG to associate instead;
                                   mutually exclusive with security_rules
  EOT

  type = map(object({
    address_prefixes  = list(string)
    service_endpoints = optional(list(string), [])
    delegation = optional(object({
      name                    = string
      service_delegation_name = string
    }))
    nsg_name                  = optional(string)
    network_security_group_id = optional(string)
    security_rules = optional(list(object({
      name                         = string
      priority                     = number
      direction                    = string
      access                       = string
      protocol                     = string
      source_port_range            = optional(string)
      source_port_ranges           = optional(list(string))
      destination_port_range       = optional(string)
      destination_port_ranges      = optional(list(string))
      source_address_prefix        = optional(string)
      source_address_prefixes      = optional(list(string))
      destination_address_prefix   = optional(string)
      destination_address_prefixes = optional(list(string))
    })), [])
  }))
  default = {}

  validation {
    condition     = alltrue([for name, cfg in var.subnets : length(cfg.address_prefixes) > 0])
    error_message = "each subnet must have at least one entry in address_prefixes."
  }

  validation {
    condition = alltrue([
      for name, cfg in var.subnets :
      !(length(cfg.security_rules) > 0 && cfg.network_security_group_id != null)
    ])
    error_message = "a subnet cannot set both security_rules (module-managed NSG) and network_security_group_id (external NSG)."
  }

  validation {
    condition = alltrue(flatten([
      for name, cfg in var.subnets : [
        for rule in cfg.security_rules : contains(["Inbound", "Outbound"], rule.direction)
      ]
    ]))
    error_message = "every security rule direction must be \"Inbound\" or \"Outbound\"."
  }

  validation {
    condition = alltrue(flatten([
      for name, cfg in var.subnets : [
        for rule in cfg.security_rules : contains(["Allow", "Deny"], rule.access)
      ]
    ]))
    error_message = "every security rule access must be \"Allow\" or \"Deny\"."
  }
}

variable "tags" {
  description = "Tags applied to every resource this module creates."
  type        = map(string)
  default     = {}
}
