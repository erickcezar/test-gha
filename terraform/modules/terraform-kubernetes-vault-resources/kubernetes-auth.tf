# Enable Kubernetes auth method on Vault
resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

# Create a service account to respond for vault in the cluster
resource "kubernetes_service_account" "vault-auth" {
  metadata {
    name = "vault-auth"
  }
}
# Create cluster binding and role binding for vault-auth sa
resource "kubectl_manifest" "vault-auth-binding" {
  yaml_body = <<YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
   name: role-tokenreview-binding
   namespace: default
roleRef:
   apiGroup: rbac.authorization.k8s.io
   kind: ClusterRole
   name: system:auth-delegator
subjects:
- kind: ServiceAccount
  name: vault-auth
  namespace: default
YAML
}

# Create a data resource to host the service account secret information (token)
data "kubernetes_secret" "vault-auth" {
  metadata {
    name      = kubernetes_service_account.vault-auth.default_secret_name
    namespace = kubernetes_service_account.vault-auth.metadata.0.namespace
  }
  depends_on = [
    kubernetes_service_account.vault-auth,
  ]
}

# Configure the Kubernetes Auth Method
resource "vault_kubernetes_auth_backend_config" "kubernetes" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = var.host
  kubernetes_ca_cert     = base64decode(var.ca_cert)
  token_reviewer_jwt     = data.kubernetes_secret.vault-auth.data["token"]
  issuer                 = "https://kubernetes.default.svc.cluster.local"
  disable_iss_validation = "true"
}
