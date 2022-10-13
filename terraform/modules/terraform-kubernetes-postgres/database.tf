resource "helm_release" "postgres" {
  name         = var.name
  chart        = "postgres-operator"
  repository   = "https://opensource.zalando.com/postgres-operator/charts/postgres-operator/"
  version      = "1.7.1"
  namespace    = var.namespace
  force_update = true
  values = [
    file("${path.module}/values/postgres-operator-values.yaml"),
  ]
}
