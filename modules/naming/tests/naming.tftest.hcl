# Behaviour tests for the naming module.
# The module declares no providers, so this runs with no cloud credentials:
#   terraform -chdir=modules/naming test

variables {
  workload    = "shop"
  environment = "prod"
  location    = "eastus2"
}

run "dashed_names_follow_the_convention" {
  command = plan

  assert {
    condition     = output.name_prefix == "shop-prod-eus2-001"
    error_message = "name_prefix did not match the expected stem"
  }

  assert {
    condition     = output.names["resource_group"] == "rg-shop-prod-eus2-001"
    error_message = "resource_group name did not match the expected convention"
  }

  assert {
    condition     = output.names["virtual_network"] == "vnet-shop-prod-eus2-001"
    error_message = "virtual_network name did not match the expected convention"
  }

  assert {
    condition     = output.resource_group_name == output.names["resource_group"]
    error_message = "resource_group_name convenience output disagrees with names map"
  }
}

run "known_region_is_abbreviated" {
  command = plan

  variables {
    location = "westeurope"
  }

  assert {
    condition     = output.name_prefix == "shop-prod-weu-001"
    error_message = "westeurope was not abbreviated to weu"
  }
}

run "unknown_region_is_slugified" {
  command = plan

  variables {
    location = "brazilsouth"
  }

  assert {
    condition     = output.name_prefix == "shop-prod-brazilsouth-001"
    error_message = "unmapped region should fall back to the raw value"
  }
}

run "instance_is_zero_padded" {
  command = plan

  variables {
    instance = 7
  }

  assert {
    condition     = output.names["resource_group"] == "rg-shop-prod-eus2-007"
    error_message = "instance number was not zero-padded to three digits"
  }
}

run "suffix_tokens_are_appended" {
  command = plan

  variables {
    suffix = ["blue"]
  }

  assert {
    condition     = output.name_prefix == "shop-prod-eus2-001-blue"
    error_message = "suffix token was not appended to the stem"
  }
}

run "storage_account_name_is_compact_and_bounded" {
  command = plan

  variables {
    workload = "storefront"
    suffix   = ["primary"]
  }

  assert {
    condition     = can(regex("^[a-z0-9]{3,24}$", output.names["storage_account"]))
    error_message = "storage_account name must be 3 to 24 lowercase alphanumeric characters"
  }
}

run "key_vault_name_is_bounded" {
  command = plan

  variables {
    workload = "storefront"
    suffix   = ["primary"]
  }

  assert {
    condition     = length(output.names["key_vault"]) <= 24
    error_message = "key_vault name must be 24 characters or fewer"
  }
}

run "baseline_tags_are_present" {
  command = plan

  assert {
    condition     = output.tags["managed_by"] == "terraform"
    error_message = "managed_by baseline tag is missing or wrong"
  }

  assert {
    condition     = output.tags["environment"] == "prod" && output.tags["workload"] == "shop"
    error_message = "environment or workload baseline tag is missing"
  }

  assert {
    condition     = !contains(keys(output.tags), "cost_center")
    error_message = "cost_center tag should be absent when the variable is not set"
  }
}

run "caller_tags_win_on_collision" {
  command = plan

  variables {
    tags = {
      environment = "override"
      team        = "platform"
    }
  }

  assert {
    condition     = output.tags["environment"] == "override"
    error_message = "caller tag should override the baseline value"
  }

  assert {
    condition     = output.tags["team"] == "platform"
    error_message = "caller-only tag should be present in the merged map"
  }
}

run "optional_tags_appear_when_set" {
  command = plan

  variables {
    cost_center = "cc-1234"
    owner       = "team-platform"
  }

  assert {
    condition     = output.tags["cost_center"] == "cc-1234" && output.tags["owner"] == "team-platform"
    error_message = "cost_center and owner should be added to tags when provided"
  }
}
