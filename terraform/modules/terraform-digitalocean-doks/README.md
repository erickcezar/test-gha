# DOKS - DigitalOcean Kubernetes Service

## Features

* Creates an Kubernetes cluster which is managed by DigitalOcean
* Creates a Kubernetes managed node Pool

## Example usage
```

locals {
  cluster_name       = "dev"
  auto_upgrade       = false
  kubernetes_version = "1.20"
  tags               = ["k8s", "development", "managed_by_terraform"]

  # the main node pool config
  size        = "s-1vcpu-2gb"
  auto_scale  = true
  min_nodes   = 1
  max_nodes   = 3
  node_count  = 1
  node_tags   = ["k8s", "development", "managed_by_terraform"]
  node_labels = {}

  # additional node pools config
  node_pools = {
     "cpu_optimized" = {
       auto_scale = true
       min_nodes  = 1
       max_nodes  = 3
       node_count = 1
       size       = "s-1vcpu-2gb"
       node_labels = {
          env        = "development"
          managed_by = "terraform"
       }
       node_taints = [
         {
           key = "dedicated"
           value = "kafka"
           effect = "NoSchedule"
         }
       ]
       node_tags = ["k8s", "development", "managed_by_terraform"]
     }
  }
}

module "doks" {
  source = "../modules/terraform-digitalocean-doks"

  cluster_name       = local.cluster_name
  vpc_uuid           = digitalocean_vpc.development.id
  auto_upgrade       = local.auto_upgrade
  region             = local.region
  kubernetes_version = local.kubernetes_version
  tags               = local.tags

  size        = local.size
  auto_scale  = local.auto_scale
  min_nodes   = local.min_nodes
  max_nodes   = local.max_nodes
  node_count  = local.node_count
  node_tags   = local.node_tags
  node_labels = local.node_labels

  node_pools = local.node_pools
}
```

This module was derived from  https://registry.terraform.io/modules/nlamirault/doks/digitalocean/latest?tab=inputs
