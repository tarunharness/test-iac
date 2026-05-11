terraform {
  required_providers {
    harness = {
      source = "harness/harness"
      version = "0.37.7"
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

resource "harness_platform_workspace" "tp6" {
  name                    = "tp6"
  identifier              = "tp6"
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

resource "harness_platform_connector_vault" "token" {
  identifier  = "my_vault_connector"
  name        = "My Vault Connector"
  description = "test"

  auth_token                        = "project.tarunvaultsecret"
  base_path                         = "/harness"
  access_type                       = "TOKEN"
  default                           = false
  renewal_interval_minutes          = 0
  secret_engine_manually_configured = true
  secret_engine_name                = "nataraja"
  secret_engine_version             = 2
  use_aws_iam                       = false
  use_k8s_auth                      = false
  vault_url                         = "http://34.135.118.41:8200"
  use_jwt_auth                      = false
}
