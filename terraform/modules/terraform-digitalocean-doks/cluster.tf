resource "digitalocean_kubernetes_cluster" "k8s" {
  name     = var.cluster_name
  region   = var.region
  version  = var.kubernetes_version_latest ? data.digitalocean_kubernetes_versions.k8s.latest_version : var.kubernetes_version
  vpc_uuid = var.vpc_uuid

  auto_upgrade = var.auto_upgrade
  tags         = var.tags

  node_pool {
    name       = format("%s-%s", var.cluster_name, var.main_nodepool_name)
    size       = element(data.digitalocean_sizes.k8s.sizes, 0).slug
    auto_scale = var.auto_scale
    min_nodes  = var.min_nodes
    max_nodes  = var.max_nodes
    node_count = var.auto_scale ? null : var.node_count
    tags       = concat(var.node_tags, ["${var.cluster_name}-lb"]) # Need tag for LB
    labels     = var.node_labels
  }

  maintenance_policy {
    start_time = var.maintenance_policy_start_time
    day        = var.maintenance_policy_day
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
      node_pool["tags"]
    ]
  }
}

resource "digitalocean_kubernetes_node_pool" "node_pools" {
  for_each = var.node_pools

  cluster_id = digitalocean_kubernetes_cluster.k8s.id

  name       = format("%s-%s", var.cluster_name, each.key)
  size       = each.value.size
  node_count = each.value.auto_scale ? null : each.value.node_count
  auto_scale = each.value.auto_scale
  min_nodes  = each.value.min_nodes
  max_nodes  = each.value.max_nodes
  tags       = concat(each.value.node_tags, ["${var.cluster_name}-lb"]) # Need tag for LB
  labels     = each.value.node_labels
  dynamic "taint" {
    for_each = each.value.node_taints
    content {
      key    = taint.value["key"]
      value  = taint.value["value"]
      effect = taint.value["effect"]
    }
  }
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }
}
