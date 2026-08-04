terraform {
  required_version = ">= 1.5.0"
  required_providers {
    null   = { source = "hashicorp/null", version = ">= 3.2.0" }
    random = { source = "hashicorp/random", version = ">= 3.6.0" }
  }
}

locals {
  tables = merge([
    for domain in var.domains : {
      for t in range(var.tables_per_domain) :
      "${domain}-${format("%03d", t)}" => {
        domain = domain
        index  = t
      }
    }
  ]...)
}

resource "null_resource" "table" {
  for_each = local.tables

  triggers = {
    name         = "${var.org}-${var.environment}-${each.key}"
    domain       = each.value.domain
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = "pk"
    range_key    = "sk"
    attributes = jsonencode([
      { name = "pk", type = "S" },
      { name = "sk", type = "S" },
      { name = "gsi1pk", type = "S" },
      { name = "gsi1sk", type = "S" },
      { name = "created_at", type = "N" },
    ])
    global_secondary_indexes = jsonencode([
      { name = "gsi1", hash_key = "gsi1pk", range_key = "gsi1sk", projection = "ALL" },
      { name = "gsi2", hash_key = "created_at", projection = "KEYS_ONLY" },
    ])
    point_in_time_recovery = "true"
    stream_enabled         = "true"
    stream_view_type       = "NEW_AND_OLD_IMAGES"
    ttl_attribute          = "expires_at"
    tags                   = jsonencode(merge(var.tags, { Name = "${var.org}-${var.environment}-${each.key}", Domain = each.value.domain }))
  }
}
