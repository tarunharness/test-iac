variable "org" {
  type        = string
  description = "Organization short name."
}

variable "environment" {
  type        = string
  description = "Environment name."
}

variable "services" {
  type        = list(string)
  description = "Services to build dashboards and alerts for."
}

variable "alerts_per_service" {
  type        = number
  description = "Number of alert rules per service."
  default     = 8
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
  default     = {}
}
