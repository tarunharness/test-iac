variable "org" {
  type        = string
  description = "Organization short name."
}

variable "environment" {
  type        = string
  description = "Environment name."
}

variable "services" {
  description = "Map of service name to its fleet configuration."
  type = map(object({
    instance_count = number
    instance_type  = string
    tier           = string
  }))
}

variable "regions" {
  type        = list(string)
  description = "Regions the fleets are spread across."
}

variable "subnet_ids" {
  description = "Subnet ids from the networking module (key => vpc id)."
  type        = map(string)
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
  default     = {}
}
