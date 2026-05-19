terraform {
  required_providers {
    harness = {
      source = "harness/harness"
      version = "0.42.7"
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

resource "harness_platform_workspace" "tp10" {
  name                    = "tp10"
  identifier              = "tp10"
  org_id                  = "default"
  project_id              = "Tarun_Test_Project"
  provisioner_type        = "terraform"
  provisioner_version     = "1.5.6"
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

  terraform_variable {
    key        = "instance_name"
    value      = "testvm"
    value_type = "string"
  }
  terraform_variable {
    key        = "type"
    value      = "t2.nano"
    value_type = "string"
  }

  environment_variable {
    key        = "key1"
    value      = "val1"
    value_type = "string"
  }
  environment_variable {
    key        = "key2"
    value      = "val2"
    value_type = "string"
  }
}
