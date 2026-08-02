# Backend bootstrap

This directory holds the one-time bootstrap that provisions the remote-state
backend itself (the S3 state bucket + DynamoDB lock table referenced by each
environment's `backend.tf`).

In a real enterprise this is applied once with a local backend, after which the
per-environment configurations point their `backend "s3"` blocks at the bucket
and table created here.

```hcl
# main.tf (illustrative — provisions state storage with a real AWS provider)
resource "aws_s3_bucket"     "tfstate" { bucket = "acme-tfstate-${var.account}" }
resource "aws_dynamodb_table" "locks"  { name   = "acme-tfstate-locks" ... }
```

Left as a placeholder here since the demo stack uses local state and mock
providers only.
