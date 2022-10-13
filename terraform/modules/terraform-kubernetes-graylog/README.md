# Graylog

* Graylog is a centralized log management solution built to open standards for capturing, storing, and enabling real-time analysis of terabytes of machine data.
* Graylog requires Elasticsearch (version 6.x.x or 7.x.x). Graylog alert not using versions of Elasticsearch above 7.11. Elasticsearch cluster must be deployed before graylog. We are using the ECK operator for that (Remember that Terraform currently does
  not support CRD on production, therefore, all operators must be configured externally,
  via kubectl):

  kubectl -n graylog apply -f operators/elasticsearch-graylog.yml

  Then, use the <es-cluster-name>-es-http service as a connection string for graylog.
  Ex: http://es-graylog-es-http.graylog.svc.cluster.local:9200

* Graylog requires also MongoDB for storing configuration. We use the mongodb Terraform
module built for that.


Example usage of this module:

```
resource "kubernetes_namespace" "graylog" {
  metadata {
    name = "graylog"
  }
}

module "k8s_mongodb" {
  source         = "../modules/terraform-kubernetes-mongodb"
  name           = "graylog-mongodb"
  namespace      = kubernetes_namespace.graylog.id
  replicas       = 3
  storageClass   = "do-block-storage"
  storage_size   = "5Gi"
  heapSize	     = "1Gi"
  enable_metrics = true
  enable_auth    = false
  architecture   = "replicaset"
}

module "graylog" {
  source              = "../modules/terraform-kubernetes-graylog"
  namespace           = kubernetes_namespace.graylog.id
  graylog_app_version = "4.1.3-1"
  storageClass        = "do-block-storage"
  storage_size        = "10Gi"
  graylog_ingress = {
    host           = "graylog-dev.marketcircle.com"
    path           = "/"
    cluster_issuer = "letsencrypt"
  }
  install_mongodb       = false
  mongodb_uri           = module.k8s_mongodb.mongodb_uri
  install_elasticsearch = false
  elasticsearch_uri     = "http://es-graylog-es-http.graylog.svc.cluster.local:9200"

  elasticsearch_version = 7
}
```
