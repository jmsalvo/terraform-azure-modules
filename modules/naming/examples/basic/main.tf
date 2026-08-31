module "naming" {
  source = "../../"

  workload    = "shop"
  environment = "prod"
  location    = "eastus2"

  cost_center = "cc-1234"

  tags = {
    application         = "storefront"
    data_classification = "public"
  }
}
