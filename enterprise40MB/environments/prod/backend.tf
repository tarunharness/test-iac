# Remote state backend.
#
# In a real enterprise this points at an S3 bucket + DynamoDB lock table
# (or Terraform Cloud). It is commented out here so the configuration can be
# initialized locally without cloud credentials. To enable, uncomment and run:
#   terraform init -reconfigure
#
# terraform {
#   backend "s3" {
#     bucket         = "acme-tfstate-prod"
#     key            = "platform/prod/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "acme-tfstate-locks"
#     encrypt        = true
#     kms_key_id     = "arn:aws:kms:us-east-1:000000000000:key/prod-tfstate"
#   }
# }
