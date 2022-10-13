resource "kubernetes_namespace" "graylog" {
  metadata {
    name = "graylog"
    labels = {
      istio-injection      = "enabled"
      managed_by_terraform = "true"
    }
  }
}

module "graylog_mongodb" {
  source         = "../modules/terraform-kubernetes-mongodb"
  name           = "graylog-mongodb"
  chart_version  = "10.28.1"
  namespace      = kubernetes_namespace.graylog.id
  storageClass   = "do-block-storage-retain"
  storage_size   = "5Gi"
  enable_metrics = true
  enable_auth    = false
  architecture   = "replicaset"
}

module "graylog" {
  source              = "../modules/terraform-kubernetes-graylog"
  namespace           = kubernetes_namespace.graylog.id
  chart_version       = "2.1.4"
  graylog_app_version = "4.3.3"
  replicas            = 3
  storageClass        = "do-block-storage-retain"
  storage_size        = "10Gi"
  graylog_ingress = {
    host           = "graylog.staging.marketcircle.net"
    path           = "/"
    cluster_issuer = "letsencrypt"
  }
  install_mongodb       = false
  mongodb_uri           = module.graylog_mongodb.mongodb_uri
  install_elasticsearch = false
  elasticsearch_uri     = "http://elasticsearch-graylog-es-http.graylog.svc.cluster.local:9200"

  elasticsearch_version = 7
}

module "fluent-bit" {
  source = "../modules/terraform-kubernetes-fluentbit"
}
