terraform {
  required_version = ">= 1.5.0"
  required_providers {
    null   = { source = "hashicorp/null", version = ">= 3.2.0" }
    random = { source = "hashicorp/random", version = ">= 3.6.0" }
  }
}

locals {
  common_tags = merge(var.tags, {
    Organization = var.org
    Environment  = var.environment
    ManagedBy    = "terraform"
    CostCenter   = "platform-engineering"
  })

  service_names = keys(var.services)
}

module "networking" {
  source = "../networking"

  org             = var.org
  environment     = var.environment
  regions         = var.regions
  vpcs_per_region = var.vpcs_per_region
  subnets_per_vpc = var.subnets_per_vpc
  tags            = local.common_tags
}

module "compute" {
  source = "../compute"

  org         = var.org
  environment = var.environment
  regions     = var.regions
  services    = var.services
  subnet_ids  = module.networking.subnet_ids
  tags        = local.common_tags
}

module "storage" {
  source = "../storage"

  org               = var.org
  environment       = var.environment
  bucket_count      = var.bucket_count
  tables_per_domain = var.tables_per_domain
  tags              = local.common_tags
}

module "iam" {
  source = "../iam"

  org               = var.org
  environment       = var.environment
  services          = local.service_names
  roles_per_service = var.roles_per_service
  tags              = local.common_tags
}

module "observability" {
  source = "../observability"

  org                = var.org
  environment        = var.environment
  services           = local.service_names
  alerts_per_service = var.alerts_per_service
  tags               = local.common_tags
}

module "data_platform" {
  source = "../data_platform"

  org            = var.org
  environment    = var.environment
  topic_count    = var.topic_count
  pipeline_count = var.pipeline_count
  tags           = local.common_tags
}
