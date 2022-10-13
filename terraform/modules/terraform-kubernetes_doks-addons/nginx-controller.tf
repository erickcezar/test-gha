resource "kubernetes_namespace" "ingress-nginx" {
  count = var.nginx_namespace == "kube-system" ? 0 : 1
  metadata {
    labels = {
      type                 = "system"
      name                 = "load-balancer"
      istio-injection      = "disabled"
      managed_by_terraform = "true"
    }
    name = var.nginx_namespace
  }
}

resource "kubernetes_config_map" "nginx-tmpl" {
  count = var.hack_ingress_nginx_enabled ? 1 : 0
  metadata {
    name      = "nginx-tmpl"
    namespace = var.nginx_namespace
  }

  data = {
    "nginx.tmpl" = "${file("${path.module}/files/nginx.tmpl")}"
  }
}

resource "helm_release" "ingress-nginx" {
  count      = var.nginx_enabled ? 1 : 0
  
  name       = var.nginx_release_name
  version    = var.nginx_version
  namespace  = var.nginx_namespace
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  timeout    = "600"
  values = [
    file("${path.module}/values/ingress-nginx-values.yaml"),
    var.pod_lifecycle,
    <<EOF
controller:
  service:
    annotations:
      service.beta.kubernetes.io/do-loadbalancer-name: ${var.cluster_name}-nginx
      service.beta.kubernetes.io/do-loadbalancer-size-unit: "${var.lb_size_unit}"
      service.beta.kubernetes.io/do-loadbalancer-enable-proxy-protocol: "${var.proxy_protocol_enabled}"
      service.beta.kubernetes.io/do-loadbalancer-hostname: "${var.cluster_name}-lb-nginx.${var.externaldns_zone}"
  config:
    # export ingress logs in a format that fluentd will understand
    # ref: https://github.com/kubernetes/ingress-nginx/issues/1664
    log-format-escape-json: "true"
    log-format-upstream: >-
      {"remote_addr": "$remote_addr",
      "cf_connecting_ip": "$http_cf_connecting_ip",
      "cf_ipcountry": "$http_cf_ipcountry",
      "remote_user": "$remote_user",
      "time_local": "$time_local",
      "request": "$request",
      "request_id": "$req_id",
      "status": "$status",
      "body_bytes_sent": "$body_bytes_sent",
      "host": "$host",
      "http_user_agent": "$http_user_agent",
      "request_length" : "$request_length",
      "request_time" : "$request_time",
      "proxy_upstream_name": "$proxy_upstream_name",
      "ingress_name": "$ingress_name",
      "ingress_namespace": "$namespace",
      "service_name": "$service_name",
      "upstream_addr": "$upstream_addr",
      "upstream_response_length": "$upstream_response_length",
      "upstream_response_time": "$upstream_response_time",
      "upstream_status": "$upstream_status",
      "ip": "$remote_addr"
      %{if var.enable_marketcircle_accesslogging_vars == true}
      ,
      "server_name": "$host",
      "customer_id":"$customer_id",
      "user_email": "$user_email_encoded",
      "oauth_scopes": "$oauth_scopes",
      "application_id": "$oauth_app_encoded",
      "device_id": "$device_id_encoded"}
      %{else}
      }
      %{endif}
EOF
    , length(var.additional_controller_config) == 0 ? "" : <<EOF
controller:
  config:
%{for k, v in var.additional_controller_config~}
    ${k} : ${v}
%{endfor~}
EOF
    , var.hack_ingress_nginx_enabled ? <<EOF
controller:
    customTemplate:
      configMapName: "nginx-tmpl"
      configMapKey: "nginx.tmpl"
tcp:
%{for k, v in var.hack_tcp_ports~}
    ${k} : ${v}
%{endfor~}
EOF
    : "",
  ]
  set {
    name  = "controller.ingressClass"
    value = var.ingress_class
  }
  set {
    name  = "controller.autoscaling.maxReplicas"
    value = var.max_nginx_replicas
  }
  set {
    name  = "controller.autoscaling.minReplicas"
    value = var.min_nginx_replicas
  }
  set {
    name  = "controller.service.nodePorts.http"
    value = var.lb_http_target_port
  }
  set {
    name  = "controller.service.nodePorts.https"
    value = var.lb_https_target_port
  }
  set {
    name  = "controller.config.use-proxy-protocol"
    value = var.proxy_protocol_enabled
    type  = "string"
  }
  set {
    name  = "controller.terminationGracePeriodSeconds"
    value = var.termination_graceful_period_seconds
  }
  set {
    name  = "controller.resources.requests.cpu"
    value = var.resource_requests_cpu
  }
  set {
    name  = "controller.resources.requests.memory"
    value = var.resource_requests_memory
  }
  set {
    name  = "controller.resources.limits.cpu"
    value = var.resource_limits_cpu
  }
  set {
    name  = "controller.resources.limits.memory"
    value = var.resource_limits_memory
  }
  set {
    name  = "controller.kind"
    value = var.use_daemonset ? "DaemonSet" : "Deployment"
  }

  set {
    name  = (var.hack_ingress_nginx_enabled ? "controller.extraArgs.default-ssl-certificate" : "0")
    value = (var.hack_ingress_nginx_enabled ? var.default_ssl_certificate : "0")
    type  = "string"
  }

}
