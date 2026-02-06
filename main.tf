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
    mount = "harness/jwt"
    role = "qa-role-5"
  }
}

# Fetch secret from Vault KV v2
data "vault_kv_secret_v2" "example" {
  mount = "nataraja"
  name = "harness/Git-3"
}

# Fetch secret from Vault KV v1 (if using KV v1)
# data "vault_generic_secret" "example_v1" {
#   path = "secret/myapp/config"
# }

# Fetch specific secret from a different path
# data "vault_kv_secret_v2" "database" {
#  mount = "secret"
#  name  = "myapp/database"
#}

# Output the secret values
output "secret_data" {
  description = "All secret data from Vault"
  value       = data.vault_kv_secret_v2.example.data
}
