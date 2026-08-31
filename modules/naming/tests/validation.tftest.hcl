# Input-validation tests. Each run supplies one deliberately invalid value and
# asserts that the matching variable validation rejects it.

variables {
  workload    = "shop"
  environment = "prod"
  location    = "eastus2"
}

run "rejects_uppercase_workload" {
  command = plan

  variables {
    workload = "Shop"
  }

  expect_failures = [var.workload]
}

run "rejects_overlong_workload" {
  command = plan

  variables {
    workload = "thisistoolong"
  }

  expect_failures = [var.workload]
}

run "rejects_unknown_environment" {
  command = plan

  variables {
    environment = "qa"
  }

  expect_failures = [var.environment]
}

run "rejects_uppercase_location" {
  command = plan

  variables {
    location = "EastUS2"
  }

  expect_failures = [var.location]
}

run "rejects_negative_instance" {
  command = plan

  variables {
    instance = -1
  }

  expect_failures = [var.instance]
}

run "rejects_fractional_instance" {
  command = plan

  variables {
    instance = 1.5
  }

  expect_failures = [var.instance]
}

run "rejects_invalid_suffix_token" {
  command = plan

  variables {
    suffix = ["has-dash"]
  }

  expect_failures = [var.suffix]
}
