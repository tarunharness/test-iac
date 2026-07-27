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

variable "sqs_queue_count" {
  description = "Number of SQS queues to create"
  type        = number
  default     = 2000
}

variable "name_prefix" {
  description = "Prefix used when naming/tagging generated resources"
  type        = string
  default     = "bulk-demo"
}

##############################################################
# SQS Queues (1000 resources)
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
  value       = var.sqs_queue_count
}

output "sqs_queue_urls" {
  description = "URLs of created SQS queues"
  value       = aws_sqs_queue.bulk[*].id
}
