resource "helm_release" "vault-secrets" {
  name         = var.name
  chart        = "vault-secrets-operator"
  repository   = "https://ricoberger.github.io/helm-charts"
  version      = "1.19.6"
  namespace    = var.namespace
  force_update = true
  values = [
    file("${path.module}/values/vault-secrets-operator-values.yaml"),
    <<EOF
podAnnotations:
  sidecar.istio.io/inject: "false"
EOF
  ]
}
