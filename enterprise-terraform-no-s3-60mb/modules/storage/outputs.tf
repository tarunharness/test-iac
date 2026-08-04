output "table_count" {
  description = "Number of tables provisioned."
  value       = length(null_resource.table)
}
