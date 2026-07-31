terraform {
  required_version = ">= 1.5.0"
  required_providers {
    null = { source = "hashicorp/null", version = ">= 3.2.0" }
  }
}

locals {
  alerts = merge([
    for svc in var.services : {
      for a in range(var.alerts_per_service) :
      "${svc}-alert-${a}" => {
        service = svc
        index   = a
        metric = element([
          "cpu_utilization", "memory_utilization", "p99_latency_ms",
          "error_rate", "request_count", "5xx_rate", "queue_depth", "saturation",
        ], a % 8)
      }
    }
  ]...)
}

resource "null_resource" "log_group" {
  for_each = toset(var.services)

  triggers = {
    name              = "/${var.org}/${var.environment}/${each.value}"
    retention_in_days = 90
    kms_key_id        = "arn:mock:kms:us-east-1:000000000000:key/${substr(sha256(each.value), 0, 36)}"
  }
}

resource "null_resource" "dashboard" {
  for_each = toset(var.services)

  triggers = {
    name = "${var.org}-${var.environment}-${each.value}-dashboard"
    body = jsonencode({
      widgets = [
        for w in range(12) : {
          type   = "metric"
          x      = (w % 3) * 8
          y      = floor(w / 3) * 6
          width  = 8
          height = 6
          properties = {
            title   = "${each.value} panel ${w}"
            region  = "us-east-1"
            stat    = "Average"
            period  = 60
            metrics = [["${var.org}/${each.value}", "metric_${w}", "Environment", var.environment]]
          }
        }
      ]
    })
  }
}

resource "null_resource" "alert" {
  for_each = local.alerts

  triggers = {
    name                = "${var.org}-${var.environment}-${each.key}"
    metric_name         = each.value.metric
    namespace           = "${var.org}/${each.value.service}"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods  = 3
    period              = 60
    statistic           = "Average"
    threshold           = 80
    treat_missing_data  = "notBreaching"
    alarm_actions = jsonencode([
      "arn:mock:sns:us-east-1:000000000000:${var.org}-${var.environment}-pagerduty",
      "arn:mock:sns:us-east-1:000000000000:${var.org}-${var.environment}-slack",
    ])
    dimensions = jsonencode({ Environment = var.environment, Service = each.value.service })
  }
}
