##############################################################
# Terraform configuration generating 10,000,000 resources total:
#   - 3,333,4 S3 buckets
#   - 3,333,3 EC2 instances
#   - 3,333,3 SQS queues
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
  default     = 33334
}

variable "ec2_instance_count" {
  description = "Number of EC2 instances to create (NOTE: will hit EC2 vCPU quota almost immediately; not realistically deployable at this scale)"
  type        = number
  default     = 33333
}

variable "sqs_queue_count" {
  description = "Number of SQS queues to create"
  type        = number
  default     = 33333
}

variable "ec2_ami" {
  description = "AMI ID to use for EC2 instances (defaults to latest Amazon Linux 2023 if not overridden)"
  type        = string
  default     = ""
}

variable "ec2_instance_type" {
  description = "Instance type for generated EC2 instances"
  type        = string
  default     = "t3.micro"
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
# S3 Buckets  (3,333,4 resources)
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
# EC2 Instances (3,333,3 resources)
##############################################################

resource "aws_instance" "bulk" {
  count = var.ec2_instance_count

  ami           = var.ec2_ami != "" ? var.ec2_ami : data.aws_ami.amazon_linux.id
  instance_type = var.ec2_instance_type

  tags = {
    Name      = "${var.name_prefix}-ec2-${count.index}"
    Index     = count.index
    Type      = "ec2-instance"
    ManagedBy = "terraform"
  }
}

##############################################################
# SQS Queues (3,333,3 resources)
##############################################################

resource "aws_sqs_queue" "bulk" {
  count = var.sqs_queue_count

  name = "${var.name_prefix}-sqs-${count.index}"

  tags = {
    Name      = "${var.name_prefix}-sqs-${count.index}"
    Index     = count.index
    Type      = "sqs-queue"
    ManagedBy = "terraform"
  }
}

##############################################################
# Outputs
##############################################################

output "total_resource_count" {
  description = "Total number of primary resources created by this configuration"
  value       = var.s3_bucket_count + var.ec2_instance_count + var.sqs_queue_count
}

output "s3_bucket_names" {
  description = "Names of created S3 buckets"
  value       = aws_s3_bucket.bulk[*].bucket
}

output "ec2_instance_ids" {
  description = "IDs of created EC2 instances"
  value       = aws_instance.bulk[*].id
}

output "sqs_queue_urls" {
  description = "URLs of created SQS queues"
  value       = aws_sqs_queue.bulk[*].id
}
