variable "org" {
  type        = string
  description = "Organization short name."
}

variable "environment" {
  type        = string
  description = "Environment name."
}

variable "bucket_count" {
  type        = number
  description = "Number of object-storage buckets to create."
  default     = 20
}

variable "tables_per_domain" {
  type        = number
  description = "Number of database tables per data domain."
  default     = 10
}

variable "domains" {
  type        = list(string)
  description = "Logical data domains."
  default     = ["billing", "identity", "catalog", "orders", "analytics"]
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
  default     = {}
}
