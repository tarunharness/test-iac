output "alert_count" {
  description = "Number of alert rules provisioned."
  value       = length(null_resource.alert)
}

output "dashboard_count" {
  description = "Number of dashboards provisioned."
  value       = length(null_resource.dashboard)
}
