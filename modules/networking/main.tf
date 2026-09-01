locals {
  # Subnets that get a module-managed NSG: they declare rules and did not bring
  # their own NSG id.
  managed_nsg_subnets = {
    for name, cfg in var.subnets : name => cfg
    if length(cfg.security_rules) > 0 && cfg.network_security_group_id == null
  }

  # subnet name -> NSG id, covering both module-created and caller-supplied NSGs.
  nsg_associations = merge(
    {
      for name, cfg in local.managed_nsg_subnets :
      name => azurerm_network_security_group.this[name].id
    },
    {
      for name, cfg in var.subnets :
      name => cfg.network_security_group_id
      if cfg.network_security_group_id != null
    },
  )
}

resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space
  dns_servers         = var.dns_servers
  tags                = var.tags
}

resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes
  service_endpoints    = each.value.service_endpoints

  dynamic "delegation" {
    for_each = each.value.delegation == null ? [] : [each.value.delegation]
    content {
      name = delegation.value.name
      service_delegation {
        name = delegation.value.service_delegation_name
      }
    }
  }
}

resource "azurerm_network_security_group" "this" {
  for_each = local.managed_nsg_subnets

  name                = coalesce(each.value.nsg_name, "nsg-${each.key}")
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  dynamic "security_rule" {
    for_each = { for rule in each.value.security_rules : rule.name => rule }
    content {
      name                         = security_rule.value.name
      priority                     = security_rule.value.priority
      direction                    = security_rule.value.direction
      access                       = security_rule.value.access
      protocol                     = security_rule.value.protocol
      source_port_range            = security_rule.value.source_port_range
      source_port_ranges           = security_rule.value.source_port_ranges
      destination_port_range       = security_rule.value.destination_port_range
      destination_port_ranges      = security_rule.value.destination_port_ranges
      source_address_prefix        = security_rule.value.source_address_prefix
      source_address_prefixes      = security_rule.value.source_address_prefixes
      destination_address_prefix   = security_rule.value.destination_address_prefix
      destination_address_prefixes = security_rule.value.destination_address_prefixes
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = local.nsg_associations

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = each.value
}
