# Networking config
locals {
  ip_range = "10.134.16.0/20"
  vpc_name = "${local.region}-staging-production"
  region   = "tor1"
}

resource "digitalocean_vpc" "staging-production" {
  name        = local.vpc_name
  description = "Network for new staging & production resources, primarily the Staging & Production Kubernetes Clusterr"
  region      = local.region
  ip_range    = local.ip_range
}

