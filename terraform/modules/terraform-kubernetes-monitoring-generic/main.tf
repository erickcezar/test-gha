resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      "type"               = "system"
      istio-injection      = "${var.istio_injection}"
      managed_by_terraform = "true"
    }
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  chart      = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  version    = "34.8.0"
  timeout    = "600"

  namespace = kubernetes_namespace.monitoring.metadata[0].name

  values = [
    file("${path.module}/values/kube-prometheus-stack-values.yaml"),
    var.prometheus_alerts_rules == "" ? local.alerts : var.prometheus_alerts_rules,
    <<EOT
alertmanager:
  config:
    global: {}
    receivers:
    - name: 'send-to-null'
    - name: 'alerts-receivers'
${var.slack_alerts_url != "" ? (var.pagerduty_service_key != "" ? local.slack_page_service : local.slack_service) : local.pagerduty_service}
    route:
      group_by: [alertname, Status]
      group_wait: 10s
      group_interval: 5m
      repeat_interval: 5m
      receiver: 'alerts-receivers'
      routes:
      - matchers:
          - alertname="Watchdog"
        receiver: 'send-to-null'
%{if var.alertmanager_ingress != null}
  ingress:
    enabled: true
    annotations:
      cert-manager.io/cluster-issuer: ${var.alertmanager_ingress.cluster_issuer}
      nginx.ingress.kubernetes.io/auth-realm: Authentication Required
      nginx.ingress.kubernetes.io/auth-secret: ${kubernetes_secret.basic_auth_htpasswd[0].metadata[0].name}
      nginx.ingress.kubernetes.io/auth-type: basic
      nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
      kubernetes.io/ingress.class: "nginx"
    hosts:
       - ${var.alertmanager_ingress.host}
    path: "${var.alertmanager_ingress.path}"
    tls:
       - secretName: alertmanager-tls
         hosts:
           - ${var.alertmanager_ingress.host}
%{endif}
%{if var.prometheus_ingress != null}
prometheus:
  ingress:
    enabled: true
    annotations:
      cert-manager.io/cluster-issuer: ${var.prometheus_ingress.cluster_issuer}
      nginx.ingress.kubernetes.io/auth-realm: Authentication Required
      nginx.ingress.kubernetes.io/auth-secret: ${kubernetes_secret.basic_auth_htpasswd[0].metadata[0].name}
      nginx.ingress.kubernetes.io/auth-type: basic
      nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
      kubernetes.io/ingress.class: "nginx"
    hosts:
       - ${var.prometheus_ingress.host}
    path: "${var.prometheus_ingress.path}"
    tls:
      - secretName: prometheus-server-tls
        hosts:
          - ${var.prometheus_ingress.host}
%{endif}
%{if var.grafana_ingress != null}
grafana:
  grafana.ini:
    auth.generic_oauth:
      enabled: true
      name: OAuth
      allow_sign_up: true
      scopes: profile,email,groups
      client_id: grafana
      client_secret: ${var.grafana_client_secret}
      auth_url: https://oauth-shared.marketcircle.dev/realms/master/protocol/openid-connect/auth
      token_url: https://oauth-shared.marketcircle.dev/realms/master/protocol/openid-connect/token
      api_url: https://oauth-shared.marketcircle.dev/realms/master/protocol/openid-connect/userinfo
      role_attribute_path: contains(groups[*], 'Admins') && 'Admin' || contains(groups[*], 'cloud') && 'Editor' || 'Viewer'
    server:
      root_url: https://${var.grafana_ingress.host}
  enabled: true
  ingress:
    enabled: true
    annotations:
      cert-manager.io/cluster-issuer: ${var.grafana_ingress.cluster_issuer}
      nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
      kubernetes.io/ingress.class: "nginx"
    hosts:
       - ${var.grafana_ingress.host}
    path: ${var.grafana_ingress.path}
    tls:
      - secretName: grafana-tls
        hosts:
          - ${var.grafana_ingress.host}
%{endif}
EOT
  ]
  set {
    name  = "alertmanager.enabled"
    value = var.pagerduty_service_key == "" && var.slack_alerts_url == "" ? "false" : "true"
  }
  set {
    name  = "alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.resources.requests.storage"
    value = var.alertmanager_persistent_volume_size
  }
  set {
    name  = "alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.storageClassName"
    value = var.alertmanager_storageclass
  }
  set {
    name  = "prometheus.prometheusSpec.replicas"
    value = var.prometheus_replica_count
  }
  set {
    name  = "prometheus.prometheusSpec.externalLabels.cluster_name"
    value = var.cluster_name
  }
  set {
    name  = "prometheus.prometheusSpec.retention"
    value = var.prometheus_retention_length
  }
  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage"
    value = var.prometheus_persistent_volume_size
  }
  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName"
    value = var.prometheus_storageclass
  }
}

resource "kubernetes_config_map" "nginx_dashboard" {
  metadata {
    name      = "nginx-dashboard"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      grafana_dashboard = "1"
      managed_by_terraform = "true"
    }
  }
  data = {
    "nginx.json" = <<EOF
${file("${path.module}/dashboards/nginx.json")}
EOF
  }
}

resource "kubernetes_config_map" "flux_cluster_dashboard" {
  metadata {
    name = "flux-cluster-dashboard"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      grafana_dashboard = "1"
      managed_by_terraform = "true"
    }
  }
  data = {
    "flux_cluster.json" = <<EOF
${file("${path.module}/dashboards/flux/cluster.json")}
EOF
  }
}

resource "kubernetes_config_map" "flux_control_plane_dashboard" {
  metadata {
    name = "flux-control-plane-dashboard"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      grafana_dashboard = "1"
      managed_by_terraform = "true"
    }
  }
  data = {
    "flux_control_plane.json" = <<EOF
${file("${path.module}/dashboards/flux/flux-control-plane.json")}
EOF
  }
}

resource "kubernetes_config_map" "istio_control_plane_dashboard" {
  metadata {
    name = "istio-control-plane-dashboard"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      grafana_dashboard = "1"
      managed_by_terraform = "true"
    }
  }
  data = {
    "istio_control_plane.json" = <<EOF
${file("${path.module}/dashboards/istio/istio-control-plane.json")}
EOF
  }
}

resource "kubernetes_config_map" "istio_mesh_dashboard" {
  metadata {
    name = "istio-mesh-dashboard"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      grafana_dashboard = "1"
      managed_by_terraform = "true"
    }
  }
  data = {
    "istio_mesh.json" = <<EOF
${file("${path.module}/dashboards/istio/istio-mesh.json")}
EOF
  }
}

resource "kubernetes_config_map" "istio_service_dashboard" {
  metadata {
    name = "istio-service-dashboard"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      grafana_dashboard = "1"
      managed_by_terraform = "true"
    }
  }
  data = {
    "istio_service.json" = <<EOF
${file("${path.module}/dashboards/istio/istio-service.json")}
EOF
  }
}

resource "kubernetes_config_map" "kafka_dashboard" {
  metadata {
    name = "kafka-dashboard"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      grafana_dashboard = "1"
      managed_by_terraform = "true"
    }
  }
  data = {
    "kafka.json" = <<EOF
${file("${path.module}/dashboards/kafka.json")}
EOF
  }
}
