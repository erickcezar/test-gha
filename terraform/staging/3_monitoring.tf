module "monitoring" {
  source                = "../modules/terraform-kubernetes-monitoring-generic"
  cluster_name          = local.cluster_name
  istio_injection       = "disabled"
  slack_alerts_channel  = "#shared-alert"
  slack_alerts_url      = "https://xxx.yyy.com/zzzzz"
  pagerduty_service_key = var.pagerduty_service_key
  grafana_client_secret = var.grafana_client_secret
  prometheus_ingress = {
    host           = "prometheus.staging.marketcircle.net"
    path           = "/"
    cluster_issuer = "letsencrypt"
  }
  alertmanager_ingress = {
    host           = "alertmanager.staging.marketcircle.net"
    path           = "/"
    cluster_issuer = "letsencrypt"
  }
  grafana_ingress = {
    host           = "grafana.staging.marketcircle.net"
    path           = "/"
    cluster_issuer = "letsencrypt"
  }
  alertmanager_storageclass         = "do-block-storage-retain"
  prometheus_storageclass           = "do-block-storage-retain"
  grafana_storageclass              = "do-block-storage-retain"
  prometheus_persistent_volume_size = "20Gi"
}
