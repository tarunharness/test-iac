output "vpc_ids" {
  description = "Map of VPC key to synthesized VPC id."
  value       = { for k, v in null_resource.vpc : k => v.triggers.vpc_id }
}

output "subnet_ids" {
  description = "Map of subnet key to VPC id it belongs to."
  value       = { for k, v in null_resource.subnet : k => v.triggers.vpc_id }
}

output "vpc_count" {
  description = "Total number of VPCs provisioned."
  value       = length(null_resource.vpc)
}

output "subnet_count" {
  description = "Total number of subnets provisioned."
  value       = length(null_resource.subnet)
}
