output "instance_ids" {
  description = "Map of instance key to synthesized instance id."
  value       = { for k, v in null_resource.instance : k => v.triggers.instance_id }
}

output "instance_count" {
  description = "Total number of compute instances."
  value       = length(null_resource.instance)
}

output "services" {
  description = "Service names deployed."
  value       = keys(var.services)
}
