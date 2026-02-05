terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.0"
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
    mount = coalesce(try(env("VAULT_JWT_MOUNT_PATH"), null), "jwt")
    
    # Role to authenticate with
    # Reads from VAULT_JWT_ROLE environment variable (required)
    role = env("VAULT_JWT_ROLE")
    
    # JWT token for authentication
    # Reads from VAULT_JWT environment variable (required)
    jwt = env("VAULT_JWT")
  }
}

# Fetch secret from Vault KV v2
data "vault_kv_secret_v2" "example" {
  mount = "secret"  # KV v2 mount path
  name  = "myapp/config"  # Secret path
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
