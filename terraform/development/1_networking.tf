# Networking config
locals {
  ip_range = "10.134.0.0/20"
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
