variable "org" {
  type        = string
  description = "Organization short name used in resource naming."
  default     = "acme"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)."
}

variable "regions" {
  type        = list(string)
  description = "Regions the platform spans."
  default     = ["us-east-1", "us-west-2", "eu-west-1"]
}

variable "services" {
  description = "Map of microservice name to fleet configuration."
  type = map(object({
    instance_count = number
    instance_type  = string
    tier           = string
  }))
}

# --- Scale knobs (tuned per environment) ---

variable "vpcs_per_region" {
  type    = number
  default = 2
}

variable "subnets_per_vpc" {
  type    = number
  default = 6
}

variable "bucket_count" {
  type    = number
  default = 20
}

variable "tables_per_domain" {
  type    = number
  default = 10
}

variable "roles_per_service" {
  type    = number
  default = 3
}

variable "alerts_per_service" {
  type    = number
  default = 8
}

variable "topic_count" {
  type    = number
  default = 50
}

variable "pipeline_count" {
  type    = number
  default = 30
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to every resource."
  default     = {}
}
