terraform {
  required_version = ">= 1.5.0"
  required_providers {
    null   = { source = "hashicorp/null", version = ">= 3.2.0" }
    random = { source = "hashicorp/random", version = ">= 3.6.0" }
  }
}

locals {
  buckets = { for i in range(var.bucket_count) :
    "${var.org}-${var.environment}-bucket-${format("%03d", i)}" => {
      index = i
      class = element(["standard", "intelligent-tiering", "glacier-ir"], i % 3)
    }
  }

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

resource "random_pet" "bucket_suffix" {
  for_each = local.buckets
  length   = 3
}

resource "null_resource" "bucket" {
  for_each = local.buckets

  triggers = {
    name          = "${each.key}-${random_pet.bucket_suffix[each.key].id}"
    storage_class = each.value.class
    versioning    = "Enabled"
    lifecycle_rules = jsonencode([
      { id = "transition-ia", days = 30, storage_class = "STANDARD_IA" },
      { id = "transition-glacier", days = 90, storage_class = "GLACIER" },
      { id = "expire", days = 3650, action = "Expiration" },
    ])
    encryption = jsonencode({
      algorithm  = "aws:kms"
      kms_key_id = "arn:mock:kms:us-east-1:000000000000:key/${substr(sha256(each.key), 0, 36)}"
      bucket_key = true
    })
    public_access_block = jsonencode({
      block_public_acls       = true
      block_public_policy     = true
      ignore_public_acls      = true
      restrict_public_buckets = true
    })
    replication = jsonencode({
      role          = "arn:mock:iam::000000000000:role/${var.org}-s3-replication"
      destination   = "arn:mock:s3:::${each.key}-replica"
      storage_class = "STANDARD_IA"
    })
    tags = jsonencode(merge(var.tags, { Name = each.key }))
  }
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
