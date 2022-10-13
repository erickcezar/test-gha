# Kubernetes DOKS config
locals {
  cluster_name              = "${local.region}-${local.environment}"
  auto_upgrade              = false
  kubernetes_version        = "1.22"
  kubernetes_version_latest = true
  tags                      = ["k8s", "${local.environment}", "managed_by_terraform"]

  # the main node pool config
  main_nodepool_name = "shared-cpu"
  size               = "s-4vcpu-8gb"
  auto_scale         = false
  min_nodes          = 1
  max_nodes          = 3
  node_count         = 1
  node_tags          = ["k8s", "${local.environment}", "managed_by_terraform"]
  node_labels = {
    env        = "${local.environment}"
    managed_by = "terraform"
  }

  # additional node pools config
  node_pools = {}
}

module "doks" {
  source = "../modules/terraform-digitalocean-doks"

  cluster_name              = local.cluster_name
  vpc_uuid                  = digitalocean_vpc.shared.id
  auto_upgrade              = local.auto_upgrade
  region                    = local.region
  kubernetes_version        = local.kubernetes_version
  kubernetes_version_latest = local.kubernetes_version_latest
  tags                      = local.tags

  main_nodepool_name = local.main_nodepool_name
  size               = local.size
  auto_scale         = local.auto_scale
  min_nodes          = local.min_nodes
  max_nodes          = local.max_nodes

  node_tags   = local.node_tags
  node_labels = local.node_labels

  node_pools = local.node_pools
}

module "addons" {
  depends_on = [module.doks]
  source     = "../modules/terraform-kubernetes_doks-addons"

  cluster_name = local.cluster_name
  vpc_uuid     = digitalocean_vpc.shared.id
  region       = local.region

  enable_lb            = false
  lb_http_target_port  = 30080
  lb_https_target_port = 30443
  lb_size              = "lb-small"
  lb_size_unit         = 1
  lb_dest_tag          = module.doks.lb_tag

  nginx_enabled            = true
  nginx_namespace          = "ingress-nginx"
  nginx_release_name       = "ingress-nginx"
  nginx_version            = "4.0.18"
  use_daemonset            = true
  resource_requests_cpu    = "50m"
  resource_requests_memory = "128Mi"
  proxy_protocol_enabled   = true
  additional_controller_config = {
    "use-proxy-protocol"       = "true"
    "compute-full-forward-for" = "true"
    "use-forward-headers"      = "true"
  }
  default_ssl_certificate    = ""
  hack_ingress_nginx_enabled = false

  istio_enabled         = false
  istio_ingress_enabled = false
  istio_namespace       = "istio-system"


  registry_server   = var.registry_server
  registry_username = var.registry_username
  registry_password = var.registry_password

  neutraldata_route_image = ""
  neutraldata_route_args  = []
  neutraldata_tolerations = []

  externaldns_token = var.externaldns_token
  externaldns_zone  = "marketcircle.dev"
}


module "cert-manager" {
  depends_on      = [module.doks]
  source          = "../modules/terraform-kubernetes-cert-manager"
  istio_injection = "disabled"
}
