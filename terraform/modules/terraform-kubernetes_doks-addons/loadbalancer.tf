resource "digitalocean_loadbalancer" "public" {
  count                  = var.enable_lb ? 1 : 0
  name                   = var.cluster_name
  region                 = var.region
  vpc_uuid               = var.vpc_uuid
  size                   = var.lb_size
  redirect_http_to_https = false

  droplet_tag = var.lb_dest_tag

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = var.lb_http_target_port
    target_protocol = "http"

  }

  forwarding_rule {
    entry_port      = 443
    entry_protocol  = "https"
    tls_passthrough = true

    target_port     = var.lb_https_target_port
    target_protocol = "https"

  }

  healthcheck {
    port     = var.lb_http_target_port
    protocol = "http"
    path     = "/healthz"
  }
}
