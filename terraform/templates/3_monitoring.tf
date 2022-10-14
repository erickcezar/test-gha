
module "monitoring" {
  source                = "../modules/terraform-kubernetes-monitoring-generic"
  cluster_name          = local.cluster_name
  istio_injection       = "disabled"
  slack_alerts_channel  = "#sandbox-alert"
  slack_alerts_url      = "https://xxx.yyy.com/zzzzz"
  pagerduty_service_key = var.pagerduty_service_key
  grafana_client_secret = var.grafana_client_secret
  prometheus_ingress = {
    host           = "prometheus-${local.region}.marketcircle.dev"
    path           = "/"
    cluster_issuer = "letsencrypt"
  }
  alertmanager_ingress = {
    host           = "alertmanager-${local.region}.marketcircle.dev"
    path           = "/"
    cluster_issuer = "letsencrypt"
  }
  grafana_ingress = {
    host           = "grafana-${local.region}.marketcircle.dev"
    path           = "/"
    cluster_issuer = "letsencrypt"
  }
  alertmanager_storageclass         = "do-block-storage-retain"
  prometheus_storageclass           = "do-block-storage-retain"
  grafana_storageclass              = "do-block-storage-retain"
  prometheus_persistent_volume_size = "100Gi"
}
