org     = "acme"
regions = ["us-east-1", "us-west-2", "eu-west-1", "ap-south-1"]

# Fleet definitions. instance_count drives the bulk of the plan size.
# Scaled ~2x relative to the 20 MB baseline to target a ~40 MB JSON plan.
services = {
  api-gateway        = { instance_count = 480, instance_type = "c6i.2xlarge", tier = "public" }
  auth-service       = { instance_count = 360, instance_type = "c6i.xlarge", tier = "private" }
  user-service       = { instance_count = 440, instance_type = "m6i.xlarge", tier = "private" }
  billing-service    = { instance_count = 400, instance_type = "m6i.2xlarge", tier = "private" }
  payment-service    = { instance_count = 400, instance_type = "m6i.2xlarge", tier = "isolated" }
  catalog-service    = { instance_count = 520, instance_type = "m6i.xlarge", tier = "private" }
  order-service      = { instance_count = 520, instance_type = "m6i.xlarge", tier = "private" }
  inventory-service  = { instance_count = 360, instance_type = "m6i.large", tier = "private" }
  notification-svc   = { instance_count = 320, instance_type = "c6i.large", tier = "private" }
  search-service     = { instance_count = 440, instance_type = "r6i.xlarge", tier = "private" }
  recommendation-svc = { instance_count = 400, instance_type = "r6i.2xlarge", tier = "private" }
  analytics-service  = { instance_count = 400, instance_type = "r6i.2xlarge", tier = "isolated" }
  fraud-detection    = { instance_count = 320, instance_type = "r6i.2xlarge", tier = "isolated" }
  shipping-service   = { instance_count = 320, instance_type = "m6i.large", tier = "private" }
  reporting-service  = { instance_count = 320, instance_type = "m6i.large", tier = "isolated" }
}

vpcs_per_region    = 6
subnets_per_vpc    = 12
bucket_count       = 400
tables_per_domain  = 80
roles_per_service  = 6
alerts_per_service = 16
topic_count        = 800
pipeline_count     = 500
