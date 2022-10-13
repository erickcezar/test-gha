#Addon to manage DNS entries in dnsimple

resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = "external-dns"
    labels = {
      istio-injection      = "enabled"
      managed_by_terraform = "true"
    }
  }
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  chart      = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  version    = "1.11.0"
  namespace  = kubernetes_namespace.external_dns.metadata[0].name
  values = [
    file("${path.module}/values/external-dns-values.yaml"),
    <<EOF
sources:
  - service
  - ingress
  - istio-gateway
policy: sync
domainFilters:
  - ${var.externaldns_zone}
provider: dnsimple
txtPrefix: "${var.cluster_name}-"
txtOwnerId: "${var.cluster_name}"
logLevel: info
EOF
,
    <<EOF
env:
  - name: DNSIMPLE_OAUTH
    value: "${var.externaldns_token}"

EOF
,
  ]
}

resource "kubectl_manifest" "external_dns_istio_service_entry" {
  count = var.istio_enabled ? 1 : 0
  yaml_body = <<YAML
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: dnsimple
  namespace: ${kubernetes_namespace.external_dns.metadata[0].name}
spec:
  hosts:
  - dnsimple.com
  - api.dnsimple.com
  location: MESH_EXTERNAL
  ports:
  - number: 443
    name: https
    protocol: HTTPS
  resolution: DNS
YAML
}

data "digitalocean_loadbalancer" "nginx-loadbalancer" {
  depends_on = [helm_release.ingress-nginx]
  name = "${var.cluster_name}-nginx"
}

# Add the nginx loadbalancer record to marketcircle domain
resource "dnsimple_zone_record" "nginx-loadbalancer" {
  zone_name = "${var.externaldns_zone}"
  name   = "${var.cluster_name}-lb-nginx"
  value  = data.digitalocean_loadbalancer.nginx-loadbalancer.ip
  type   = "A"
  ttl    = 3600
}

data "digitalocean_loadbalancer" "istio-loadbalancer" {
  count = var.istio_ingress_enabled ? 1 : 0
  depends_on = [helm_release.istio-ingress]
  name = "${var.cluster_name}-istio"
}

# Add the nginx loadbalancer record to marketcircle domain
resource "dnsimple_zone_record" "istio-loadbalancer" {
  count = var.istio_ingress_enabled ? 1 : 0
  depends_on = [
    data.digitalocean_loadbalancer.istio-loadbalancer[0]
  ]
  zone_name = "${var.externaldns_zone}"
  name   = "${var.cluster_name}-lb-istio"
  value  = data.digitalocean_loadbalancer.istio-loadbalancer[0].ip
  type   = "A"
  ttl    = 3600
}
