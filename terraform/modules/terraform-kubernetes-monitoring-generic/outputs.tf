output "namespace" {
  description = "Namespace used by Prometheus"
  value       = helm_release.prometheus.namespace
}

