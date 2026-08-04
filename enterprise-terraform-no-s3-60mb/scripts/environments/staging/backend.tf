# Remote state backend (disabled for local runs — see prod/backend.tf).
#
# terraform {
#   backend "s3" {
#     bucket         = "acme-tfstate-staging"
#     key            = "platform/staging/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "acme-tfstate-locks"
#     encrypt        = true
#   }
# }
