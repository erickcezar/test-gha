## TODO: Add approle permissions for the vault resources to create
# resource "vault_audit" "file_audit" {
#   type = "file"
#   options = {
#     "file_path" = "/vault/audit"
#   }
# }


module "vault_resources" {
  host    = data.digitalocean_kubernetes_cluster.cluster.endpoint
  ca_cert = data.digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate
  source  = "../modules/terraform-kubernetes-vault-resources"
}

################ OIDC Integration Keycloak ##########################

resource "vault_identity_oidc_key" "keycloak_provider_key" {
  name      = "keycloak"
  algorithm = "RS256"
}

resource "vault_jwt_auth_backend" "keycloak" {
  path               = "oidc"
  type               = "oidc"
  default_role       = "default"
  oidc_discovery_url = "https://oauth-shared.marketcircle.dev/realms/master"
  oidc_client_id     = "vault-dev"
  oidc_client_secret = var.vault_dev_keycloak_secret

  tune {
    audit_non_hmac_request_keys  = []
    audit_non_hmac_response_keys = []
    default_lease_ttl            = "1h"
    listing_visibility           = "unauth"
    max_lease_ttl                = "1h"
    passthrough_request_headers  = []
    token_type                   = "default-service"
  }
}

resource "vault_jwt_auth_backend_role" "default" {
  backend       = vault_jwt_auth_backend.keycloak.path
  role_name     = "default"
  role_type     = "oidc"
  token_ttl     = 3600
  token_max_ttl = 3600

  bound_audiences = ["vault-dev"]
  user_claim      = "sub"
  claim_mappings = {
    preferred_username = "username"
    email              = "email"
  }

  allowed_redirect_uris = [
    "https://vault.marketcircle.dev/ui/vault/auth/oidc/oidc/callback",
    "https://vault.marketcircle.dev/oidc/callback",
    "http://localhost:8250/oidc/callback"
  ]
  groups_claim = "/resource_access/vault-dev/roles"
}

module "admin" {
  source                       = "../modules/terraform-kubernetes-vault-external-groups"
  external_accessor            = vault_jwt_auth_backend.keycloak.accessor
  vault_identity_oidc_key_name = vault_identity_oidc_key.keycloak_provider_key.name
  groups = [
    {
      group_name = "admin"
      policies   = ["admin"]
    }
  ]
}

module "bespin-developer" {
  source                       = "../modules/terraform-kubernetes-vault-external-groups"
  external_accessor            = vault_jwt_auth_backend.keycloak.accessor
  vault_identity_oidc_key_name = vault_identity_oidc_key.keycloak_provider_key.name
  groups = [
    {
      group_name = "bespin-developer"
      policies   = ["bespin-developer"]
    }
  ]
}

