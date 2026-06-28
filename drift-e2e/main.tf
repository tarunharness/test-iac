terraform {
  required_providers {
    harness = {
      source  = "harness/harness"
      version = "0.42.8"
    }
  }
}
provider "harness" {
  endpoint         = "https://tarunisrani.pr2.harness.io/gateway"
  account_id       = "HXw8QlnhRxCzAGNV4uiAKg"
  platform_api_key = var.hns_token
}
variable "hns_token" {
  type      = string
  sensitive = true
}
resource "harness_platform_project" "drift_e2e" {
  identifier  = "driftE2E"
  name        = "driftE2E"
  org_id      = "default"
  description = "managed-by-iacm-v1"
}
