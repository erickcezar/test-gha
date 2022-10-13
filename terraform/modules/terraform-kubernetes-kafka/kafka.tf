# The namespace kafka is where the actual kafka cluster will be deployed
resource "kubernetes_namespace" "kafka" {
  metadata {
    name = "kafka"
  }
}

# Then namespace kafka-operator is where the operator will be deployed
resource "kubernetes_namespace" "kafka-operator" {
  metadata {
    name = "kafka-operator"
    labels = {
      istio-injection = "enabled"
      managed_by_terraform = "true"
    }
  }
}


# based on https://strimzi.io/docs/operators/latest/deploying.html#deploying-cluster-operator-helm-chart-str
# IMPORTANT: please note https://strimzi.io/docs/operators/latest/deploying.html#upgrading_the_cluster_operator_using_helm_chart for chart upgrades
resource "helm_release" "kafka" {
  name              = var.name
  chart             = "strimzi-kafka-operator"
  repository        = "https://strimzi.io/charts/"
  version           = "0.26.0"
  namespace         = kubernetes_namespace.kafka-operator.id
  dependency_update = true
  force_update      = false
  create_namespace  = false
  values = [
    file("${path.module}/values/values.yaml"),
    <<EOT
%{if var.toleration != null~}
tolerations:
- key: "${var.toleration.key}"
  operator: "${var.toleration.operator}"
  effect: "${var.toleration.effect}"
%{endif~}
%{if var.node_selector != ""~}
nodeSelector:
  ${var.node_selector}
%{endif~}
EOT
  ]
  set {
    name  = "watchNamespaces"
    value = "{${join(",", var.namespaces_to_watch)}}"
  }
}
