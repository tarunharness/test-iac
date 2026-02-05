terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# Vault provider configuration using JWT authentication
# The provider will automatically read these environment variables:
# - VAULT_ADDR (required)
# - VAULT_NAMESPACE (optional, for Vault Enterprise)
# - VAULT_JWT_MOUNT_PATH (default: "jwt")
# - VAULT_JWT_ROLE (required)
# - VAULT_JWT (required)
provider "vault" {
  # Address and namespace are automatically read from environment variables:
  # address   = env.VAULT_ADDR
  # namespace = env.VAULT_NAMESPACE
  
  # JWT authentication configuration
  # All values are read directly from environment variables
  auth_login_jwt {
    # Mount path where JWT auth is enabled in Vault
    # Reads from VAULT_JWT_MOUNT_PATH environment variable (default: "jwt")
    mount = "harness/jwt"
    
    # Role to authenticate with
    # Reads from VAULT_JWT_ROLE environment variable (required)
    role = "qa-role-5"
    
    # JWT token for authentication
    # Reads from VAULT_JWT environment variable (required)
    jwt = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6IkVJQTBpVDFDcE5OTFhIOXlWU01IN05pQVFGeWZTWGxZdGZRbWtNVVhiZzgifQ.eyJzdWIiOiJlOXFEdlJfMFJZV1hSdmJKSFpDeUNnIiwiaXNzIjoiaHR0cHM6Ly9xYS5oYXJuZXNzLmlvL25nL2FwaS9vaWRjL2FjY291bnQvZTlxRHZSXzBSWVdYUnZiSkhaQ3lDZyIsImF1ZCI6Imhhcm5lc3Mvand0IiwiZXhwIjoxNzcwMzExNjMwLCJpYXQiOjE3NzAzMDgwMzAsInVwbiI6IklBQ01NYW5hZ2VyIiwiYWNjb3VudF9pZCI6ImU5cUR2Ul8wUllXWFJ2YkpIWkN5Q2ciLCJvcmdhbml6YXRpb25faWQiOiJkZWZhdWx0IiwicHJvamVjdF9pZCI6IlRhcnVuX1Rlc3RfUHJvamVjdF8wMSIsImNvbm5lY3Rvcl9pZCI6InZhdWx0and0IiwiY29udGV4dCI6IlBJUEVMSU5FX0VYRUNVVElPTiJ9.hkg-YlGXSnYtpB5m7mYNpJSsTgg2hESTv5MnzqhaZfmmimoTnB_ZPl6ygFZaE94ep4-SCyNOGUVQLvO3Bi3Vxh_4cZyb96ouMU1CX6f3Qgjrh_adYOaX5nK4MvGKJ436VyaBxAoP8pZDVChGud71LArYBoTFPCt8Hy_ErFSlg_4amheBlsHIxRbkXg-2BdqpqfO3pv6Rn-5atGIVJED8BtTUJMnEiXZW1HIUd9AwUJRM0TWaqZ_Vf-K9bhi-NmPqTEP2XahzqKQpyaxlPbtGBdJRNsKf7ArNjV9mSDtj1u9PE1-EXM4ZvhkmwXA2O2EpvjPpdz2D4oUPaq7WsvM27w"
  }
}

# Fetch secret from Vault KV v2
data "vault_kv_secret_v2" "example" {
  mount = "harness"  # KV v2 mount path
  name  = "Git-3"  # Secret path
}

# Fetch secret from Vault KV v1 (if using KV v1)
# data "vault_generic_secret" "example_v1" {
#   path = "secret/myapp/config"
# }

# Fetch specific secret from a different path
data "vault_kv_secret_v2" "database" {
  mount = "secret"
  name  = "myapp/database"
}

# Output the secret values
output "secret_data" {
  description = "All secret data from Vault"
  value       = data.vault_kv_secret_v2.example.data
  sensitive   = true
}

output "specific_secret_value" {
  description = "A specific secret value (api_key)"
  value       = try(data.vault_kv_secret_v2.example.data["api_key"], "not-found")
  sensitive   = true
}
