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
# data "vault_kv_secret_v2" "example" {
#  mount = "nataraja"
#  name = "harness/Git-3"
#}

# Fetch secret from Vault KV v1 (if using KV v1)
# data "vault_generic_secret" "example_v1" {
#   path = "secret/myapp/config"
# }

# Fetch specific secret from a different path
# data "vault_kv_secret_v2" "database" {
#  mount = "secret"
#  name  = "myapp/database"
#}

# data "vault_generic_secret" "example" {
#   path = "secret/nataraja/harness"
# }

# output "db_password" {
#   value     = data.vault_generic_secret.example.data["Git-3"]
#   sensitive = false
# }

# Fetch secret from Vault
# Equivalent to: vault kv get nataraja/harness/Git-3
data "vault_kv_secret_v2" "git_secret" {
  mount = "nataraja"        # secret engine name
  name  = "harness/Git-3"   # full path to the secret
}

# Output the secret data to console
output "secret_data" {
  description = "All key-value pairs in the Git-3 secret"
  value       = data.vault_kv_secret_v2.git_secret.data
  sensitive   = true
}

# Output metadata (optional)
output "secret_metadata" {
  description = "Metadata about the secret"
  value = {
    version      = data.vault_kv_secret_v2.git_secret.version
    created_time = data.vault_kv_secret_v2.git_secret.created_time
    path         = data.vault_kv_secret_v2.git_secret.path
  }
}
