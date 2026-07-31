terraform {
  required_version = ">= 1.5.0"
  required_providers {
    null   = { source = "hashicorp/null", version = ">= 3.2.0" }
    random = { source = "hashicorp/random", version = ">= 3.6.0" }
  }
}

locals {
  # Build a flat list of every VPC we need across all regions.
  vpcs = flatten([
    for region in var.regions : [
      for idx in range(var.vpcs_per_region) : {
        key    = "${region}-vpc-${idx}"
        region = region
        index  = idx
        cidr   = "10.${index(var.regions, region) * 16 + idx}.0.0/16"
      }
    ]
  ])

  vpc_map = { for v in local.vpcs : v.key => v }

  # Build a flat list of subnets across every VPC.
  subnets = flatten([
    for v in local.vpcs : [
      for s in range(var.subnets_per_vpc) : {
        key     = "${v.key}-subnet-${s}"
        vpc_key = v.key
        region  = v.region
        az      = "${v.region}${element(var.availability_zones, s % length(var.availability_zones))}"
        cidr    = cidrsubnet(v.cidr, 8, s)
        tier    = s % 3 == 0 ? "public" : (s % 3 == 1 ? "private" : "isolated")
      }
    ]
  ])

  subnet_map = { for s in local.subnets : s.key => s }
}

resource "random_id" "vpc" {
  for_each    = local.vpc_map
  byte_length = 8
  keepers = {
    region = each.value.region
    cidr   = each.value.cidr
  }
}

resource "null_resource" "vpc" {
  for_each = local.vpc_map

  triggers = {
    name        = "${var.org}-${var.environment}-${each.key}"
    region      = each.value.region
    cidr_block  = each.value.cidr
    vpc_id      = "vpc-${random_id.vpc[each.key].hex}"
    dns_support = "true"
    dns_host    = "true"
    tenancy     = "default"
    flow_logs = jsonencode({
      enabled           = true
      traffic_type      = "ALL"
      log_destination   = "arn:mock:logs:${each.value.region}:000000000000:log-group:/vpc/${each.key}"
      max_aggregation   = 60
      deliver_logs_role = "arn:mock:iam::000000000000:role/${var.org}-flow-logs"
    })
    tags = jsonencode(merge(var.tags, {
      Name        = "${var.org}-${var.environment}-${each.key}"
      Environment = var.environment
      ManagedBy   = "terraform"
      Region      = each.value.region
    }))
  }
}

resource "null_resource" "subnet" {
  for_each = local.subnet_map

  triggers = {
    name                    = "${var.org}-${var.environment}-${each.key}"
    vpc_id                  = null_resource.vpc[each.value.vpc_key].triggers.vpc_id
    availability_zone       = each.value.az
    cidr_block              = each.value.cidr
    tier                    = each.value.tier
    map_public_ip           = each.value.tier == "public" ? "true" : "false"
    assign_ipv6             = "false"
    route_table_association = "rtb-${substr(sha256(each.key), 0, 17)}"
    nacl_id                 = "acl-${substr(sha256("${each.key}-nacl"), 0, 17)}"
    tags = jsonencode(merge(var.tags, {
      Name = "${var.org}-${var.environment}-${each.key}"
      Tier = each.value.tier
    }))
  }
}

# Route tables: one per subnet tier per VPC.
resource "null_resource" "route_table" {
  for_each = local.subnet_map

  triggers = {
    name   = "${var.org}-${var.environment}-${each.key}-rt"
    vpc_id = null_resource.vpc[each.value.vpc_key].triggers.vpc_id
    routes = jsonencode([
      { destination = "0.0.0.0/0", target = each.value.tier == "public" ? "igw-mock" : "nat-mock" },
      { destination = "10.0.0.0/8", target = "local" },
      { destination = "172.16.0.0/12", target = "pcx-mock" },
    ])
  }
}

# Security groups with a set of rules each.
resource "null_resource" "security_group" {
  for_each = local.vpc_map

  triggers = {
    name   = "${var.org}-${var.environment}-${each.key}-sg"
    vpc_id = null_resource.vpc[each.key].triggers.vpc_id
    ingress = jsonencode([
      { protocol = "tcp", from = 443, to = 443, cidr = "0.0.0.0/0", desc = "https" },
      { protocol = "tcp", from = 80, to = 80, cidr = "0.0.0.0/0", desc = "http" },
      { protocol = "tcp", from = 22, to = 22, cidr = "10.0.0.0/8", desc = "ssh-internal" },
      { protocol = "tcp", from = 5432, to = 5432, cidr = "10.0.0.0/8", desc = "postgres" },
      { protocol = "tcp", from = 6379, to = 6379, cidr = "10.0.0.0/8", desc = "redis" },
    ])
    egress = jsonencode([
      { protocol = "-1", from = 0, to = 0, cidr = "0.0.0.0/0", desc = "all" },
    ])
  }
}
