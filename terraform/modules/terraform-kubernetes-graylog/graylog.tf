resource "helm_release" "graylog" {
  name              = "graylog"
  chart             = "graylog"
  repository        = "https://charts.kong-z.com"
  version           = var.chart_version
  namespace         = var.namespace
  dependency_update = true
  force_update      = false
  timeout           = 600
  values = [
    file("${path.module}/values/graylog-values.yaml"),
    <<EOT
graylog:
%{if var.graylog_ingress != null}
  ingress:
    enabled: true
    annotations:
      cert-manager.io/cluster-issuer: ${var.graylog_ingress.cluster_issuer}
      nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
      kubernetes.io/ingress.class: "nginx"
    hosts:
       - ${var.graylog_ingress.host}
    path: ${var.graylog_ingress.path}
    tls:
       - secretName: graylog-server-tls
         hosts:
           - ${var.graylog_ingress.host}
%{endif}
EOT
  ]
  set {
    name  = "graylog.replicas"
    value = var.replicas
  }
  set {
    name  = "graylog.image.tag"
    value = var.graylog_app_version
  }
  set {
    name  = "graylog.persistence.storageClass"
    value = var.storageClass
  }
  set {
    name  = "graylog.persistence.size"
    value = var.storage_size
  }
  set {
    name  = "tags.install-mongodb"
    value = var.install_mongodb
  }
  set {
    name  = "graylog.mongodb.uri"
    value = var.mongodb_uri
  }

  set {
    name  = "tags.install-elasticsearch"
    value = var.install_elasticsearch
  }
  set {
    name  = "graylog.elasticsearch.hosts"
    value = var.elasticsearch_uri
  }
  set {
    name  = "graylog.elasticsearch.version"
    value = var.elasticsearch_version
  }
}
