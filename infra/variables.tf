variable "aws_region" {
  description = "AWS region where EC2 instance will be created"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID to use for the instance (Amazon Linux 2 recommended)"
  type        = string
  default     = "ami-07860a2d7eb515d9a" # Amazon Linux 2 in us-east-1
}