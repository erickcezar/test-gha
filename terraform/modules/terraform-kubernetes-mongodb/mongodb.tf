resource "helm_release" "mongodb" {
  name         = var.name
  chart        = "https://charts.bitnami.com/bitnami/mongodb-${var.chart_version}.tgz"
  namespace    = var.namespace
  force_update = true
  timeout      = 600
  values = [
    file("${path.module}/values/mongodb-values.yaml"),
  ]
  set {
    name  = "global.nameOverride"
    value = var.name
  }
  set {
    name  = "architecture"
    value = var.architecture
  }
  set {
    name  = "global.storageClass"
    value = var.storageClass
  }
  set {
    name  = "replica.replicaCount"
    value = var.replica_count
  }
  set {
    name  = "persistence.size"
    value = var.storage_size
  }
  set {
    name  = "metrics.enabled"
    value = var.enable_metrics
  }
  set {
    name  = "auth.enabled"
    value = var.enable_auth
  }
}
