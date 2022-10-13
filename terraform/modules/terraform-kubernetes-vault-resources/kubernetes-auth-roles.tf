resource "vault_kubernetes_auth_backend_role" "cert-manager" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "cert-manager"
  bound_service_account_names      = ["cert-manager"]
  bound_service_account_namespaces = ["cert-manager"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.cert-manager.name]
}

resource "vault_kubernetes_auth_backend_role" "vault-secrets-operator" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "vault-secrets-operator"
  bound_service_account_names      = ["vault-secrets-operator"]
  bound_service_account_namespaces = ["vault"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.vault-secrets-operator.name]
}

resource "vault_kubernetes_auth_backend_role" "bespin" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "bespin"
  bound_service_account_names      = ["bespin", "bespin*", "daylite-api*"]
  bound_service_account_namespaces = ["dev"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.bespin.name]
  lifecycle {
    ignore_changes = [
      # Ignore changes to bound_service_account_namespaces, because the deployer updates these
      bound_service_account_namespaces,
    ]
  }
}

resource "vault_kubernetes_auth_backend_role" "theron" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "theron"
  bound_service_account_names      = ["theron"]
  bound_service_account_namespaces = ["dev"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.theron.name]
  lifecycle {
    ignore_changes = [
      # Ignore changes to bound_service_account_namespaces, because the deployer updates these
      bound_service_account_namespaces,
    ]
  }
}

resource "vault_kubernetes_auth_backend_role" "daylite-api" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "daylite-api"
  bound_service_account_names      = ["daylite-api*", "bespin*"]
  bound_service_account_namespaces = ["dev", "bespin-*"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.daylite-api.name]
  lifecycle {
    ignore_changes = [
      # Ignore changes to bound_service_account_namespaces, because the deployer updates these
      bound_service_account_namespaces,
    ]
  }
}


resource "vault_kubernetes_auth_backend_role" "yavin-server" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "yavin-server"
  bound_service_account_names      = ["yavin-server"]
  bound_service_account_namespaces = ["dev"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.yavin-server.name]
  lifecycle {
    ignore_changes = [
      # Ignore changes to bound_service_account_namespaces, because the deployer updates these
      bound_service_account_namespaces,
    ]
  }
}

resource "vault_kubernetes_auth_backend_role" "tatooine" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "tatooine"
  bound_service_account_names      = ["tatooine"]
  bound_service_account_namespaces = ["dev"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.tatooine.name]
  lifecycle {
    ignore_changes = [
      # Ignore changes to bound_service_account_namespaces, because the deployer updates these
      bound_service_account_namespaces,
    ]
  }
}

resource "vault_kubernetes_auth_backend_role" "kashyyyk" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "kashyyyk"
  bound_service_account_names      = ["kashyyyk"]
  bound_service_account_namespaces = ["beta"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.kashyyyk.name]
  lifecycle {
    ignore_changes = [
      # Ignore changes to bound_service_account_namespaces, because the deployer updates these
      bound_service_account_namespaces,
    ]
  }
}

resource "vault_kubernetes_auth_backend_role" "deployer" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "deployer"
  bound_service_account_names      = ["deployer"]
  bound_service_account_namespaces = ["deployer"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.deployer.name]
}


resource "vault_kubernetes_auth_backend_role" "serverenvironments" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "serverenvironments"
  bound_service_account_names      = ["serverenvironments"]
  bound_service_account_namespaces = ["dev"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.serverenvironments.name]
}
