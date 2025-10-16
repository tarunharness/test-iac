terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

provider "null" {}

# Embed a large static JSON data structure in the triggers
resource "null_resource" "example" {
  count = 1

  triggers = {
    large_data = file("large_data.json")
  }
}