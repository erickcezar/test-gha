resource "kubernetes_namespace" "consul" {
  metadata {
    labels = {
      managed_by_terraform = "true"
    }
    name = "consul"
  }
}

resource "helm_release" "consul" {
  name       = "consul"
  namespace  = kubernetes_namespace.consul.id
  chart      = "consul"
  repository = "https://helm.releases.hashicorp.com"
  version    = var.chart_version
  values = [
    file("${path.module}/values/consul-values.yaml"),
    <<EOF

client:
  join:
%{for ip in var.client_join_ips~}
    - ${ip}
%{endfor~}

  tolerations: |
  ${var.client_tolerations}
  
  extraConfig: |
    ${var.client_extra_config}

syncCatalog:
  k8sAllowNamespaces:
%{for namespace in var.sync_catalog_k8s_allow_namespaces~}
    - ${namespace}
%{endfor~}
EOF
    ,
  ]

  set {
    name  = "global.datacenter"
    value = var.consul_datacenter
  }
  set {
    name  = "global.image"
    value = "consul:${var.consul_version}"
  }
  set {
    name  = "server.enabled"
    value = var.enable_server
  }
  set {
    name  = "client.enabled"
    value = var.enable_client
  }
  set {
    name  = "client.exposeGossipPorts"
    value = var.client_expose_gossip_ports
  }
  set {
    name  = "syncCatalog.enabled"
    value = var.sync_catalog
  }
  set {
    name  = "syncCatalog.toConsul"
    value = var.sync_catalog_to_consul
  }
  set {
    name  = "syncCatalog.toK8S"
    value = var.sync_catalog_to_k8s
  }
  set {
    name  = "syncCatalog.consulPrefix"
    value = var.sync_catalog_consul_prefix
  }
  set {
    name  = "syncCatalog.k8sTag"
    value = var.sync_catalog_k8s_tag
  }
  set {
    name  = "global.gossipEncryption.secretName"
    value = kubernetes_secret.gossipEncryption.metadata[0].name
  }
  set {
    name  = "global.gossipEncryption.secretKey"
    value = "key"
  }

}

resource "kubernetes_secret" "gossipEncryption" {

  metadata {
    name      = "gossip-encryption"
    namespace = kubernetes_namespace.consul.id
  }

  data = {
    "key" = var.gossip_encryption_key
  }

}
