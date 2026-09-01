terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  # Placeholder so `terraform validate` works without credentials. Set a real
  # subscription (ARM_SUBSCRIPTION_ID or here) before `plan` / `apply`.
  subscription_id = "00000000-0000-0000-0000-000000000000"
}
