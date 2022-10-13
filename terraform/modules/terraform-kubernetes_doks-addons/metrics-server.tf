resource "helm_release" "metrics" {
  name              = "metrics"
  chart             = "metrics-server"
  repository        = "https://charts.bitnami.com/bitnami"
  version           = "5.10.13"
  namespace         = "kube-system"
  dependency_update = true
  force_update      = true
  values = [
    file("${path.module}/values/metric-server-values.yaml"),
  ]
}
