org     = "acme"
regions = ["us-east-1", "us-west-2", "eu-west-1", "ap-south-1"]

# Fleet definitions. instance_count drives the bulk of the plan size.
# S3 buckets have been removed from this variant; instance counts are bumped
# ~+50/service to backfill the ~1,400 removed bucket resources and hold ~60 MB.
# NOTE: Terraform's range() rejects >1024 values, so per-count knobs stay <= 1024.
services = {
  api-gateway        = { instance_count = 810, instance_type = "c6i.2xlarge", tier = "public" }
  auth-service       = { instance_count = 630, instance_type = "c6i.xlarge", tier = "private" }
  user-service       = { instance_count = 750, instance_type = "m6i.xlarge", tier = "private" }
  billing-service    = { instance_count = 690, instance_type = "m6i.2xlarge", tier = "private" }
  payment-service    = { instance_count = 690, instance_type = "m6i.2xlarge", tier = "isolated" }
  catalog-service    = { instance_count = 870, instance_type = "m6i.xlarge", tier = "private" }
  order-service      = { instance_count = 870, instance_type = "m6i.xlarge", tier = "private" }
  inventory-service  = { instance_count = 630, instance_type = "m6i.large", tier = "private" }
  notification-svc   = { instance_count = 570, instance_type = "c6i.large", tier = "private" }
  search-service     = { instance_count = 750, instance_type = "r6i.xlarge", tier = "private" }
  recommendation-svc = { instance_count = 690, instance_type = "r6i.2xlarge", tier = "private" }
  analytics-service  = { instance_count = 690, instance_type = "r6i.2xlarge", tier = "isolated" }
  fraud-detection    = { instance_count = 570, instance_type = "r6i.2xlarge", tier = "isolated" }
  shipping-service   = { instance_count = 570, instance_type = "m6i.large", tier = "private" }
  reporting-service  = { instance_count = 570, instance_type = "m6i.large", tier = "isolated" }
}

vpcs_per_region    = 9
subnets_per_vpc    = 12
tables_per_domain  = 140
roles_per_service  = 6
alerts_per_service = 16
topic_count        = 1000
pipeline_count     = 900
