variable "org" {
  type        = string
  description = "Organization short name."
}

variable "environment" {
  type        = string
  description = "Environment name."
}

variable "topic_count" {
  type        = number
  description = "Number of streaming topics to provision."
  default     = 50
}

variable "pipeline_count" {
  type        = number
  description = "Number of ETL pipelines to provision."
  default     = 30
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
  default     = {}
}
