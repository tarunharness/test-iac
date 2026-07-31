output "role_count" {
  description = "Number of IAM roles provisioned."
  value       = length(null_resource.role)
}

output "role_arns" {
  description = "Map of role key to synthesized ARN."
  value       = { for k, v in null_resource.role : k => "arn:mock:iam::000000000000:role/${v.triggers.name}" }
}
