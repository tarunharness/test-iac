variable "org" {
  type    = string
  default = "acme"
}

variable "regions" {
  type    = list(string)
  default = ["us-east-1", "us-west-2", "eu-west-1"]
}

variable "services" {
  type = map(object({
    instance_count = number
    instance_type  = string
    tier           = string
  }))
}

variable "vpcs_per_region" {
  type = number
}

variable "subnets_per_vpc" {
  type = number
}

variable "bucket_count" {
  type = number
}

variable "tables_per_domain" {
  type = number
}

variable "roles_per_service" {
  type = number
}

variable "alerts_per_service" {
  type = number
}

variable "topic_count" {
  type = number
}

variable "pipeline_count" {
  type = number
}
