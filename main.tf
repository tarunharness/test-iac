terraform {
  required_providers {
    harness = {
      source = "harness/harness"
      version = "0.42.8"
    }
  }
}
provider "harness" {
  endpoint         = "https://qa.harness.io/gateway"
  account_id       = "25NKDX79QPC-YTyninmxRQ"
  platform_api_key = var.test_token 
}

variable "test_token" {
  type = string
  description = "test token"
}

resource "harness_platform_workspace" "tp14" {
  name                    = "tp14"
  identifier              = "tp14"
  org_id                  = "default"
  project_id              = "Tarun_Test_Project"
  provisioner_type        = "awscdk"
  provisioner_version     = "2.1107.0"
  repository              = ""
  repository_branch       = "main"
  repository_path         = ""
  cost_estimation_enabled = true
  repository_connector    = "tarunGitConnector"
  
  connector {                                                                                                                                                                                                      
    connector_ref = "Tarun_AWS_CloudProvider_Test"
    type          = "aws"
  }

  connector {                                                                                                                                                                                                      
    connector_ref = "tarun_vault"
    type          = "vault"
  }
}
