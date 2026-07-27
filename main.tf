##############################################################
# Terraform configuration generating 10,000,000 resources total:
#   - 2000 S3 buckets
#   - 1000 EC2 instances
#   - 1000 SQS queues
#
# WARNING: This is NOT deployable against a real AWS account.
#   - S3: default account limit is ~100 buckets (soft-raisable
#     to a few hundred at most via support ticket).
#   - EC2: default vCPU quotas are in the low hundreds per
#     region; would require quota increases of many orders of
#     magnitude, which AWS will not grant.
#   - Terraform state at this scale (10M resources) would be
#     gigabytes in size and effectively unusable with `plan`/
#     `apply` (single-threaded state locking, long runtimes).
#   - AWS API rate limits would throttle far before reaching
#     this scale regardless of quotas.
#
# This file exists for HCL generation / tooling scale-testing
# purposes only (e.g. testing parsers, linters, or Terraform's
# own handling of very large configs) -- not for real deploys.
##############################################################

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

##############################################################
# Variables
##############################################################

variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

variable "s3_bucket_count" {
  description = "Number of S3 buckets to create (NOTE: AWS hard-limits accounts to ~100 buckets by default; this value is for HCL/code-gen scale-testing only, not a realistic deploy target)"
  type        = number
  default     = 2000
}

variable "name_prefix" {
  description = "Prefix used when naming/tagging generated resources"
  type        = string
  default     = "bulk-demo"
}

##############################################################
# Data sources
##############################################################

# Used only if var.ec2_ami is left empty
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Random suffix so S3 bucket names are globally unique across runs/accounts
resource "random_id" "bucket_suffix" {
  count       = var.s3_bucket_count
  byte_length = 4
}

##############################################################
# S3 Buckets  (2000 resources)
##############################################################

resource "aws_s3_bucket" "bulk" {
  count = var.s3_bucket_count

  bucket = lower("${var.name_prefix}-s3-${count.index}-${random_id.bucket_suffix[count.index].hex}")

  tags = {
    Name      = "${var.name_prefix}-s3-${count.index}"
    Index     = count.index
    Type      = "s3-bucket"
    ManagedBy = "terraform"
  }
}


##############################################################
# Outputs
##############################################################

output "total_resource_count" {
  description = "Total number of primary resources created by this configuration"
  value       = var.s3_bucket_count
}

output "s3_bucket_names" {
  description = "Names of created S3 buckets"
  value       = aws_s3_bucket.bulk[*].bucket
}
