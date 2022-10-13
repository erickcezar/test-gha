resource "helm_release" "fluent_bit" {
  name         = var.name
  chart        = "fluent-bit"
  repository   = "https://fluent.github.io/helm-charts"
  version      = "0.19.20"
  namespace    = var.namespace
  force_update = true
  values = [
    file("${path.module}/values/fluentbit-values.yaml"),
  ]
}
