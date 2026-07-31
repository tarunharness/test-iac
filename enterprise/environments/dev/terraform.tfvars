org     = "acme"
regions = ["us-east-1"]

# Dev runs a slim footprint of each service.
services = {
  api-gateway     = { instance_count = 4, instance_type = "t3.medium", tier = "public" }
  auth-service    = { instance_count = 3, instance_type = "t3.medium", tier = "private" }
  user-service    = { instance_count = 3, instance_type = "t3.medium", tier = "private" }
  billing-service = { instance_count = 3, instance_type = "t3.medium", tier = "private" }
  catalog-service = { instance_count = 3, instance_type = "t3.medium", tier = "private" }
  order-service   = { instance_count = 3, instance_type = "t3.medium", tier = "private" }
}

vpcs_per_region    = 1
subnets_per_vpc    = 3
bucket_count       = 10
tables_per_domain  = 3
roles_per_service  = 2
alerts_per_service = 4
topic_count        = 10
pipeline_count     = 5
