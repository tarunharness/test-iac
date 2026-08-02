output "bucket_count" {
  description = "Number of buckets provisioned."
  value       = length(null_resource.bucket)
}

output "table_count" {
  description = "Number of tables provisioned."
  value       = length(null_resource.table)
}
