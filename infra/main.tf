terraform {
  required_providers {
    aws  = { source = "hashicorp/aws",  version = "~> 5.0" }
    null = { source = "hashicorp/null", version = "~> 3.0" }
  }
}
provider "aws" {
  region = var.aws_region
}
resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = var.instance_type
  tags = {
    Name = "opentofu-ec2-demo"
  }
}
# Added for IAC-6516 reproduction — extra resource that exists in code but not in state
resource "null_resource" "bugrepro_extra" {
  triggers = {
    marker = "iac6516-extra-resource"
  }
}
