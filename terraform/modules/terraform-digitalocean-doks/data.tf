data "digitalocean_kubernetes_versions" "k8s" {
  version_prefix = var.kubernetes_version
}

data "digitalocean_sizes" "k8s" {
  filter {
    key    = "slug"
    values = [var.size]
  }

  filter {
    key    = "regions"
    values = [var.region]
  }

}
