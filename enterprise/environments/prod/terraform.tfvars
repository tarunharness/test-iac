org     = "acme"
regions = ["us-east-1", "us-west-2", "eu-west-1", "ap-south-1"]

# Fleet definitions. instance_count drives the bulk of the plan size.
services = {
  api-gateway        = { instance_count = 240, instance_type = "c6i.2xlarge", tier = "public" }
  auth-service       = { instance_count = 180, instance_type = "c6i.xlarge", tier = "private" }
  user-service       = { instance_count = 220, instance_type = "m6i.xlarge", tier = "private" }
  billing-service    = { instance_count = 200, instance_type = "m6i.2xlarge", tier = "private" }
  payment-service    = { instance_count = 200, instance_type = "m6i.2xlarge", tier = "isolated" }
  catalog-service    = { instance_count = 260, instance_type = "m6i.xlarge", tier = "private" }
  order-service      = { instance_count = 260, instance_type = "m6i.xlarge", tier = "private" }
  inventory-service  = { instance_count = 180, instance_type = "m6i.large", tier = "private" }
  notification-svc   = { instance_count = 160, instance_type = "c6i.large", tier = "private" }
  search-service     = { instance_count = 220, instance_type = "r6i.xlarge", tier = "private" }
  recommendation-svc = { instance_count = 200, instance_type = "r6i.2xlarge", tier = "private" }
  analytics-service  = { instance_count = 200, instance_type = "r6i.2xlarge", tier = "isolated" }
  fraud-detection    = { instance_count = 160, instance_type = "r6i.2xlarge", tier = "isolated" }
  shipping-service   = { instance_count = 160, instance_type = "m6i.large", tier = "private" }
  reporting-service  = { instance_count = 160, instance_type = "m6i.large", tier = "isolated" }
}

vpcs_per_region    = 3
subnets_per_vpc    = 12
bucket_count       = 200
tables_per_domain  = 40
roles_per_service  = 6
alerts_per_service = 16
topic_count        = 400
pipeline_count     = 250
