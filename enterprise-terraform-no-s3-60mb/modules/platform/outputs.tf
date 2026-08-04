output "summary" {
  description = "High-level count of resources produced by the platform."
  value = {
    environment = var.environment
    vpcs        = module.networking.vpc_count
    subnets     = module.networking.subnet_count
    instances   = module.compute.instance_count
    tables      = module.storage.table_count
    iam_roles   = module.iam.role_count
    alerts      = module.observability.alert_count
    dashboards  = module.observability.dashboard_count
    topics      = module.data_platform.topic_count
    pipelines   = module.data_platform.pipeline_count
  }
}
