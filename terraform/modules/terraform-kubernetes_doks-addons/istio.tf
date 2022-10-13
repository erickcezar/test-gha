resource "kubernetes_namespace" "istio-system" {
  count = var.istio_enabled ? 1 : 0

  metadata {
    name = var.istio_namespace
    labels = {
      managed_by_terraform = "true"
    }

  }
}

resource "kubernetes_namespace" "kiali-operator" {
  count = var.istio_enabled ? 1 : 0

  metadata {
    name = var.kiali_operator_namespace
    labels = {
      istio-injection : "enabled"
      managed_by_terraform = "true"
    }
  }
}


resource "helm_release" "istio-base" {
  count = var.istio_enabled ? 1 : 0

  name       = "istio-base"
  chart      = "base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  version    = "1.13.4"
  namespace  = var.istio_namespace
  values = [
    file("${path.module}/values/istio-base-values.yaml"),
  ]
}

resource "kubectl_manifest" "istio_telemetry" {
  count = var.istio_enabled ? 1 : 0
  depends_on = [helm_release.istio-base]
  yaml_body = <<YAML
apiVersion: telemetry.istio.io/v1alpha1
kind: Telemetry
metadata:
  name: default
  namespace: ${var.istio_namespace}
spec:
  accessLogging:
  - providers:
    - name: envoy
YAML
}

resource "helm_release" "istiod" {
  count = var.istio_enabled ? 1 : 0

  depends_on = [helm_release.istio-base]
  name       = "istiod"
  chart      = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  version    = "1.13.4"
  namespace  = var.istio_namespace
  values = [
    file("${path.module}/values/istiod-values.yaml"),
  ]
}

resource "helm_release" "istio-ingress" {
  count = var.istio_ingress_enabled ? 1 : 0

  depends_on = [helm_release.istio-base]
  name       = "istio-ingress"
  chart      = "gateway"
  repository = "https://istio-release.storage.googleapis.com/charts"
  version    = "1.13.4"
  namespace  = var.istio_namespace
  values = [
    file("${path.module}/values/istio-gateway-values.yaml"),
    <<EOF
service:
  type: LoadBalancer
  ports:
  - name: status-port
    port: 15021
    protocol: TCP
    targetPort: 15021
  - name: http2
    port: 80
    protocol: TCP
    targetPort: 80
  - name: https
    port: 443
    protocol: TCP
    targetPort: 443
  - name: bespin-accountsservice
    port: 11000
    protocol: TCP
    targetPort: 11000
  annotations:
    service.beta.kubernetes.io/do-loadbalancer-name: "${var.cluster_name}-istio"
    service.beta.kubernetes.io/do-loadbalancer-size-unit: "${var.lb_size_unit}"
    service.beta.kubernetes.io/do-loadbalancer-enable-proxy-protocol: "${var.proxy_protocol_enabled}"
    service.beta.kubernetes.io/do-loadbalancer-hostname: "${var.cluster_name}-lb-istio.${var.externaldns_zone}"
EOF
  ]
}


resource "kubectl_manifest" "envoy-filter-proxy-protocol" {
  count = var.istio_enabled ? 1 : 0
  depends_on = [helm_release.istio-base]
  yaml_body = <<YAML
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: proxy-protocol
  namespace: ${var.istio_namespace}
spec:
  workloadSelector:
    labels:
      istio: ingress
  configPatches:
  - applyTo: LISTENER
    patch:
      operation: MERGE
      value:
        listener_filters:
          name: "envoy.filters.listener.proxy_protocol"
          name: "envoy.filters.listener.tls_inspector"
YAML
}

resource "helm_release" "kiali-operator" {
  count = var.istio_enabled ? 1 : 0

  depends_on = [helm_release.istio-base, helm_release.istiod]
  name       = "kiali-operator"
  chart      = "kiali-operator"
  repository = "https://kiali.org/helm-charts"
  version    = "1.47.0"
  namespace  = var.kiali_operator_namespace
  values = [
    file("${path.module}/values/kiali-operator-values.yaml"),
    <<EOF
cr:
  create: true
  namespace: "istio-system"

  spec:
    external_services:
      istio:
        component_status:
          components:
          - app_label: "istio-ingress"
            is_core: true
            is_proxy: true
            namespace: istio-system
      prometheus:
        url: http://prometheus-kube-prometheus-prometheus.monitoring.svc.cluster.local:9090
      grafana:
        enabled: false
      #   in_cluster_url: 'http://grafana.monitoring.svc.cluster.local:3000'
      #   url: https://monitoring.marketcircle.dev/grafana
      tracing:
        enabled: false
EOF
,
  ]
}

# resource "kubernetes_ingress" "kiali" {
#   depends_on = [helm_release.kiali-operator]
#   metadata {
#     name = "kiali"
#     namespace = var.istio_namespace
#     annotations = {
#       "kubernetes.io/ingress.class"                    = "nginx"
#       "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
#       "cert-manager.io/cluster-issuer"                 = "letsencrypt"
#     }
#   }
#   spec {
#     tls {
#       hosts       = ["kiali.marketcircle.dev"]
#       secret_name = "kiali-tls"
#     }
#     rule {
#       host = "kiali.marketcircle.dev"
#       http {
#         path {
#           path = "/"
#           backend {
#             service_name = "kiali"
#             service_port = 20001
#           }
#         }
#       }
#     }
#   }
# }
