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

variable "ec2_instance_count" {
  description = "Number of EC2 instances to create (NOTE: will hit EC2 vCPU quota almost immediately; not realistically deployable at this scale)"
  type        = number
  default     = 2000
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

##############################################################
# EC2 Instances 1000 resources)
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
# Outputs
##############################################################

output "total_resource_count" {
  description = "Total number of primary resources created by this configuration"
  value       = var.ec2_instance_count
}

output "ec2_instance_ids" {
  description = "IDs of created EC2 instances"
  value       = aws_instance.bulk[*].id
}
