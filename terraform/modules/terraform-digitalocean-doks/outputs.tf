output "id" {
  value = digitalocean_kubernetes_cluster.k8s.id
}

output "name" {
  value = digitalocean_kubernetes_cluster.k8s.name
}

output "endpoint" {
  value = digitalocean_kubernetes_cluster.k8s.endpoint
}

output "kube_config" {
  value = digitalocean_kubernetes_cluster.k8s.kube_config
}

output "lb_tag" {
  value = "${var.cluster_name}-lb"
}
