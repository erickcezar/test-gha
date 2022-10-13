resource "helm_release" "redis" {
  name         = var.name
  chart        = "redis-operator"
  repository   = "https://ot-container-kit.github.io/helm-charts/"
  version      = "0.9.0"
  namespace    = var.namespace
  force_update = true
  values = [
    file("${path.module}/values/redis-values.yaml"),
  ]
  set {
    name  = "redisOperator.name"
    value = var.name
  }
}
