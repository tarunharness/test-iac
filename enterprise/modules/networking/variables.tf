variable "org" {
  description = "Organization short name used for naming."
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)."
  type        = string
}

variable "regions" {
  description = "List of regions to deploy network fabric into."
  type        = list(string)
}

variable "vpcs_per_region" {
  description = "Number of VPCs provisioned per region."
  type        = number
  default     = 2
}

variable "subnets_per_vpc" {
  description = "Number of subnets per VPC (spread across AZs)."
  type        = number
  default     = 6
}

variable "availability_zones" {
  description = "Availability zone suffixes to spread subnets across."
  type        = list(string)
  default     = ["a", "b", "c"]
}

variable "tags" {
  description = "Common tags applied to every resource."
  type        = map(string)
  default     = {}
}
