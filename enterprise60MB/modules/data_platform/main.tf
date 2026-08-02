terraform {
  required_version = ">= 1.5.0"
  required_providers {
    null = { source = "hashicorp/null", version = ">= 3.2.0" }
  }
}

locals {
  topics = { for i in range(var.topic_count) :
    "topic-${format("%04d", i)}" => {
      index      = i
      partitions = element([6, 12, 24, 48], i % 4)
    }
  }

  pipelines = { for i in range(var.pipeline_count) :
    "pipeline-${format("%04d", i)}" => {
      index  = i
      engine = element(["spark", "flink", "dbt"], i % 3)
    }
  }
}

resource "null_resource" "topic" {
  for_each = local.topics

  triggers = {
    name               = "${var.org}.${var.environment}.${each.key}"
    partitions         = each.value.partitions
    replication_factor = 3
    config = jsonencode({
      "retention.ms"        = 604800000
      "cleanup.policy"      = "delete"
      "compression.type"    = "zstd"
      "min.insync.replicas" = 2
      "max.message.bytes"   = 1048576
      "segment.ms"          = 86400000
    })
    schema = jsonencode({
      type = "record"
      name = "Event${each.value.index}"
      fields = [
        { name = "event_id", type = "string" },
        { name = "timestamp", type = "long" },
        { name = "payload", type = "string" },
        { name = "source", type = "string" },
        { name = "version", type = "int" },
      ]
    })
  }
}

resource "null_resource" "pipeline" {
  for_each = local.pipelines

  triggers = {
    name        = "${var.org}-${var.environment}-${each.key}"
    engine      = each.value.engine
    schedule    = "cron(0 */${(each.value.index % 12) + 1} * * ? *)"
    concurrency = (each.value.index % 4) + 1
    steps = jsonencode([
      { name = "extract", type = "source", format = "parquet" },
      { name = "validate", type = "quality-check", rules = ["not_null", "unique_pk", "referential_integrity"] },
      { name = "transform", type = "sql", materialization = "incremental" },
      { name = "load", type = "sink", target = "warehouse", mode = "merge" },
      { name = "publish", type = "notify", channels = ["slack", "email"] },
    ])
    resources = jsonencode({
      driver_cores    = 4
      driver_memory   = "8g"
      executor_cores  = 4
      executor_memory = "16g"
      num_executors   = (each.value.index % 10) + 2
    })
  }
}
