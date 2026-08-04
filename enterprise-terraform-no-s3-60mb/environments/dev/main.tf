module "platform" {
  source = "../../modules/platform"

  org         = var.org
  environment = "dev"
  regions     = var.regions
  services    = var.services

  vpcs_per_region    = var.vpcs_per_region
  subnets_per_vpc    = var.subnets_per_vpc
  tables_per_domain  = var.tables_per_domain
  roles_per_service  = var.roles_per_service
  alerts_per_service = var.alerts_per_service
  topic_count        = var.topic_count
  pipeline_count     = var.pipeline_count

  tags = {
    Team = "platform"
    Tier = "non-critical"
  }
}
