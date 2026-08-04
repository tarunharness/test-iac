terraform {
  required_version = ">= 1.5.0"
  required_providers {
    null   = { source = "hashicorp/null", version = ">= 3.2.0" }
    random = { source = "hashicorp/random", version = ">= 3.6.0" }
  }
}

locals {
  subnet_keys = length(var.subnet_ids) > 0 ? keys(var.subnet_ids) : ["default"]

  # Expand every service into individual instance definitions.
  instances = flatten([
    for svc_name, svc in var.services : [
      for i in range(svc.instance_count) : {
        key           = "${svc_name}-${format("%04d", i)}"
        service       = svc_name
        index         = i
        instance_type = svc.instance_type
        tier          = svc.tier
        region        = element(var.regions, i % length(var.regions))
        subnet        = element(local.subnet_keys, i % length(local.subnet_keys))
      }
    ]
  ])

  instance_map = { for inst in local.instances : inst.key => inst }

  # A chunk of realistic-looking bootstrap config attached to each instance.
  user_data_template = <<-EOT
    #cloud-config
    package_update: true
    package_upgrade: true
    packages:
      - docker.io
      - awscli
      - jq
      - curl
      - unzip
      - chrony
      - amazon-cloudwatch-agent
    write_files:
      - path: /etc/app/config.yaml
        permissions: '0644'
        content: |
          service:
            name: SERVICE_NAME
            environment: ENVIRONMENT
            region: REGION
            log_level: info
            metrics:
              enabled: true
              interval_seconds: 15
              endpoint: https://metrics.internal.ORG.io/ingest
            tracing:
              enabled: true
              sampler_ratio: 0.1
              collector: otel-collector.observability.svc.cluster.local:4317
            feature_flags:
              enable_circuit_breaker: true
              enable_retry_budget: true
              max_retries: 3
              retry_backoff_ms: 200
            database:
              pool_size: 20
              connection_timeout_ms: 5000
              statement_timeout_ms: 30000
    runcmd:
      - systemctl enable docker
      - systemctl start docker
      - docker run -d --restart=always --name app -p 8080:8080 registry.internal.ORG.io/SERVICE_NAME:latest
  EOT
}

resource "random_id" "instance" {
  for_each    = local.instance_map
  byte_length = 8
}

resource "null_resource" "instance" {
  for_each = local.instance_map

  triggers = {
    name              = "${var.org}-${var.environment}-${each.key}"
    instance_id       = "i-${random_id.instance[each.key].hex}"
    service           = each.value.service
    instance_type     = each.value.instance_type
    tier              = each.value.tier
    region            = each.value.region
    availability_zone = "${each.value.region}${element(["a", "b", "c"], each.value.index % 3)}"
    subnet_ref        = each.value.subnet
    ami               = "ami-${substr(sha256("${each.key}-ami"), 0, 17)}"
    private_ip        = "10.${each.value.index % 250}.${(each.value.index * 7) % 250}.${(each.value.index * 13) % 250}"
    ebs_optimized     = "true"
    monitoring        = "true"
    root_volume = jsonencode({
      size_gb    = 100
      type       = "gp3"
      iops       = 3000
      throughput = 125
      encrypted  = true
      kms_key_id = "arn:mock:kms:${each.value.region}:000000000000:key/${substr(sha256(each.key), 0, 36)}"
    })
    user_data = replace(replace(replace(replace(
      local.user_data_template,
      "SERVICE_NAME", each.value.service),
      "ENVIRONMENT", var.environment),
      "REGION", each.value.region),
    "ORG", var.org)
    tags = jsonencode(merge(var.tags, {
      Name        = "${var.org}-${var.environment}-${each.key}"
      Service     = each.value.service
      Tier        = each.value.tier
      Environment = var.environment
      Region      = each.value.region
    }))
  }
}

# One load balancer per service.
resource "null_resource" "load_balancer" {
  for_each = var.services

  triggers = {
    name         = "${var.org}-${var.environment}-${each.key}-alb"
    scheme       = each.value.tier == "public" ? "internet-facing" : "internal"
    type         = "application"
    idle_timeout = 60
    listeners = jsonencode([
      { port = 443, protocol = "HTTPS", ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06" },
      { port = 80, protocol = "HTTP", action = "redirect-to-https" },
    ])
    health_check = jsonencode({
      path                = "/healthz"
      interval            = 30
      timeout             = 5
      healthy_threshold   = 3
      unhealthy_threshold = 3
      matcher             = "200-299"
    })
  }
}

# Autoscaling policy per service.
resource "null_resource" "autoscaling" {
  for_each = var.services

  triggers = {
    name             = "${var.org}-${var.environment}-${each.key}-asg"
    min_size         = 2
    max_size         = each.value.instance_count * 2
    desired_capacity = each.value.instance_count
    policies = jsonencode([
      { metric = "CPUUtilization", target = 65, scale_out_cooldown = 120, scale_in_cooldown = 300 },
      { metric = "RequestCountPerTarget", target = 1000, scale_out_cooldown = 60, scale_in_cooldown = 180 },
    ])
  }
}
