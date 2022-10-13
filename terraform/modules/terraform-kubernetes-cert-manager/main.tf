resource "kubernetes_namespace" "cert-manager" {
  metadata {
    annotations = {
      name = "cert-manager"
    }
    labels = {
      "certmanager.k8s.io/disable-validation" = "true"
      "type"                                  = "system"
      "name"                                  = "cert-manager"
      istio-injection                         = "${var.istio_injection}"
      managed_by_terraform                    = "true"
    }
    name = "cert-manager"
  }
}

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.9.1"
  namespace  = kubernetes_namespace.cert-manager.metadata.0.name
  values = [
    <<EOF
installCRDs: true
EOF
,
  ]
}

resource "kubectl_manifest" "letsencrypt-cluster-issuer" {
  depends_on = [
    helm_release.cert-manager
  ]
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt
spec:
  acme:
    email: cloud@marketcircle.com
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-key
    solvers:
    - http01:
        ingress:
          class: nginx
YAML
}
