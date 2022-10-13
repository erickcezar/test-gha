# Networking config
locals {
  ip_range = "10.154.0.0/16"
  vpc_name = "${local.region}-${local.environment}"
}

resource "digitalocean_vpc" "development" {
  name        = local.vpc_name
  description = "Network for Development Resources, primarily the Development Kubernetes Cluster"
  region      = local.region
  ip_range    = local.ip_range
}

# resource "digitalocean_domain" "internal" {
#   name       = "marketcircle.internal"
# }