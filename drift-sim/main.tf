terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}
resource "aws_ec2_tag" "drift_sim" {
  resource_id = "i-0964aee9e86f6c0aa"
  key         = "DriftSim"
  value       = "true"
}
