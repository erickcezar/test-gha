# Networking config
locals {
  ip_range = "10.134.16.0/20"
  vpc_name = "${local.region}-${local.environment}"
}

resource "digitalocean_vpc" "production" {
  name        = local.vpc_name
  description = "Network for Production Resources, primarily the Production Kubernetes Cluster"
  region      = local.region
  ip_range    = local.ip_range
}

# resource "digitalocean_domain" "internal" {
#   name       = "marketcircle.internal"
# }
