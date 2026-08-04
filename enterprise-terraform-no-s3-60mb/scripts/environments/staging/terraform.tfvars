org     = "acme"
regions = ["us-east-1", "us-west-2"]

# Staging mirrors prod's service list at reduced fleet sizes.
services = {
  api-gateway        = { instance_count = 24, instance_type = "c6i.large", tier = "public" }
  auth-service       = { instance_count = 18, instance_type = "c6i.large", tier = "private" }
  user-service       = { instance_count = 22, instance_type = "m6i.large", tier = "private" }
  billing-service    = { instance_count = 20, instance_type = "m6i.large", tier = "private" }
  payment-service    = { instance_count = 20, instance_type = "m6i.large", tier = "isolated" }
  catalog-service    = { instance_count = 26, instance_type = "m6i.large", tier = "private" }
  order-service      = { instance_count = 26, instance_type = "m6i.large", tier = "private" }
  search-service     = { instance_count = 22, instance_type = "r6i.large", tier = "private" }
  recommendation-svc = { instance_count = 20, instance_type = "r6i.large", tier = "private" }
  analytics-service  = { instance_count = 20, instance_type = "r6i.large", tier = "isolated" }
}

vpcs_per_region    = 2
subnets_per_vpc    = 6
tables_per_domain  = 15
roles_per_service  = 4
alerts_per_service = 8
topic_count        = 100
pipeline_count     = 60
