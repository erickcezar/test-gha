resource "kubernetes_namespace" "elasticsearch" {
  metadata {
    name = "elasticsearch"
    labels = {
      istio-injection      = "disabled"
      managed_by_terraform = "true"
    }
  }
}

# The following resource will create the operator ONLY.
# the actual Elastic Search clusters should be deployed by
# executing kubectl apply -n <namespace> -f operators/elasticsearch-<es-cluster>.yml
# Managing CRD in terraform is experimental.
resource "helm_release" "elasticsearch" {
  name       = "eck"
  chart      = "eck-operator"
  version    = "1.8.0"
  namespace  = kubernetes_namespace.elasticsearch.id
  repository = "https://helm.elastic.co"
}
