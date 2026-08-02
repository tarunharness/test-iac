variable "org" {
  type        = string
  description = "Organization short name."
}

variable "environment" {
  type        = string
  description = "Environment name."
}

variable "roles_per_service" {
  type        = number
  description = "Number of IAM roles created per service."
  default     = 3
}

variable "services" {
  type        = list(string)
  description = "Services that need IAM roles."
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
  default     = {}
}
