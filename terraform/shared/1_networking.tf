# Networking config
locals {
  ip_range = "10.134.32.0/20"
  vpc_name = "${local.region}-${local.environment}"
}

resource "digitalocean_vpc" "shared" {
  name        = local.vpc_name
  description = "Network for Shared Resources, primarily the Shared Kubernetes Cluster"
  region      = local.region
  ip_range    = local.ip_range
}
