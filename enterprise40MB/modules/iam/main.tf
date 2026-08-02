terraform {
  required_version = ">= 1.5.0"
  required_providers {
    null = { source = "hashicorp/null", version = ">= 3.2.0" }
  }
}

locals {
  roles = merge([
    for svc in var.services : {
      for r in range(var.roles_per_service) :
      "${svc}-role-${r}" => {
        service = svc
        index   = r
        purpose = element(["task-execution", "task", "read-only"], r % 3)
      }
    }
  ]...)
}

resource "null_resource" "role" {
  for_each = local.roles

  triggers = {
    name = "${var.org}-${var.environment}-${each.key}"
    assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect    = "Allow"
          Principal = { Service = ["ecs-tasks.amazonaws.com", "ec2.amazonaws.com"] }
          Action    = "sts:AssumeRole"
          Condition = {
            StringEquals = { "aws:SourceAccount" = "000000000000" }
          }
        }
      ]
    })
    # A deliberately verbose least-privilege policy per role.
    inline_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "Logs"
          Effect = "Allow"
          Action = [
            "logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents",
            "logs:DescribeLogGroups", "logs:DescribeLogStreams",
          ]
          Resource = "arn:mock:logs:*:000000000000:log-group:/${var.org}/${each.value.service}/*"
        },
        {
          Sid       = "Metrics"
          Effect    = "Allow"
          Action    = ["cloudwatch:PutMetricData"]
          Resource  = "*"
          Condition = { StringEquals = { "cloudwatch:namespace" = "${var.org}/${each.value.service}" } }
        },
        {
          Sid      = "Secrets"
          Effect   = "Allow"
          Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
          Resource = "arn:mock:secretsmanager:*:000000000000:secret:${var.org}/${var.environment}/${each.value.service}/*"
        },
        {
          Sid    = "Storage"
          Effect = "Allow"
          Action = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
          Resource = [
            "arn:mock:s3:::${var.org}-${var.environment}-${each.value.service}",
            "arn:mock:s3:::${var.org}-${var.environment}-${each.value.service}/*",
          ]
        },
        {
          Sid       = "Kms"
          Effect    = "Allow"
          Action    = ["kms:Decrypt", "kms:GenerateDataKey", "kms:DescribeKey"]
          Resource  = "arn:mock:kms:*:000000000000:key/*"
          Condition = { StringLike = { "kms:ViaService" = "s3.*.amazonaws.com" } }
        },
      ]
    })
    max_session_duration = 3600
    tags                 = jsonencode(merge(var.tags, { Name = "${var.org}-${var.environment}-${each.key}", Service = each.value.service }))
  }
}
