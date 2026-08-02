output "topic_count" {
  description = "Number of streaming topics provisioned."
  value       = length(null_resource.topic)
}

output "pipeline_count" {
  description = "Number of ETL pipelines provisioned."
  value       = length(null_resource.pipeline)
}
