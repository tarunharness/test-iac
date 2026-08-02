org     = "acme"
regions = ["us-east-1", "us-west-2", "eu-west-1", "ap-south-1"]

# Fleet definitions. instance_count drives the bulk of the plan size.
# Scaled ~3x relative to the 20 MB baseline to target a ~60 MB JSON plan.
# NOTE: Terraform's range() rejects >1024 values, so per-count knobs stay
# <= 1024; extra volume comes from more instances/buckets/pipelines instead.
services = {
  api-gateway        = { instance_count = 760, instance_type = "c6i.2xlarge", tier = "public" }
  auth-service       = { instance_count = 580, instance_type = "c6i.xlarge", tier = "private" }
  user-service       = { instance_count = 700, instance_type = "m6i.xlarge", tier = "private" }
  billing-service    = { instance_count = 640, instance_type = "m6i.2xlarge", tier = "private" }
  payment-service    = { instance_count = 640, instance_type = "m6i.2xlarge", tier = "isolated" }
  catalog-service    = { instance_count = 820, instance_type = "m6i.xlarge", tier = "private" }
  order-service      = { instance_count = 820, instance_type = "m6i.xlarge", tier = "private" }
  inventory-service  = { instance_count = 580, instance_type = "m6i.large", tier = "private" }
  notification-svc   = { instance_count = 520, instance_type = "c6i.large", tier = "private" }
  search-service     = { instance_count = 700, instance_type = "r6i.xlarge", tier = "private" }
  recommendation-svc = { instance_count = 640, instance_type = "r6i.2xlarge", tier = "private" }
  analytics-service  = { instance_count = 640, instance_type = "r6i.2xlarge", tier = "isolated" }
  fraud-detection    = { instance_count = 520, instance_type = "r6i.2xlarge", tier = "isolated" }
  shipping-service   = { instance_count = 520, instance_type = "m6i.large", tier = "private" }
  reporting-service  = { instance_count = 520, instance_type = "m6i.large", tier = "isolated" }
}

vpcs_per_region    = 9
subnets_per_vpc    = 12
bucket_count       = 700
tables_per_domain  = 140
roles_per_service  = 6
alerts_per_service = 16
topic_count        = 1000
pipeline_count     = 900
