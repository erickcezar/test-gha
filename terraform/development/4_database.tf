####
# The Development Cluster relies only on k8 databases (operators)
# the following modules define managed databases on digitalocean
# that should be used on staging and production environments
####
# locals {
#   fw_rules = {
#     "rule01" = {
#       type  = "k8s"
#       value = module.doks.id
#     }
#     "rule02" = {
#       type  = "ip_addr"
#       value = "10.8.0.0/24"
#     }
#   }
# }
#
# module "managed_postgres" {
#   source = "../modules/terraform-digitalocean-db"
#  # source  = "app.terraform.io/vmfarms/db/digitalocean"
#  # version = "1.0.0"
#
#   db_cluster_name         = "dev-postgres"
#   region                  = local.region
#   vpc_uuid                = digitalocean_vpc.development.id
#   db_engine               = "pg"
#   db_version              = "11"
#   db_droplet_size         = "db-s-1vcpu-1gb"
#   db_node_count           = 1
#   db_tags                 = ["postgres", "development", "managed_by_terraform"]
#   maintenance_window_day  = "saturday"
#   maintenance_window_hour = "11:00"
#
#   enable_read_replica  = true
#   replica_droplet_size = "db-s-1vcpu-1gb"
#
#   databases = {
#     "scarif" = {
#       mode          = "transaction"
#       pool_size     = 10
#       database_user = "scarif_app"
#     }
#     "bespin" = {
#       mode          = "session"
#       pool_size     = 10
#       database_user = "bespin_app"
#     }
#   }
#
#   fw_rules = local.fw_rules
#
# }
#
# module "managed_redis" {
#   source = "../modules/terraform-digitalocean-db"
#   # source  = "app.terraform.io/vmfarms/db/digitalocean"
#   # version = "1.0.0"
#
#   db_cluster_name         = "dev-redis"
#   region                  = local.region
#   vpc_uuid                = digitalocean_vpc.development.id
#   db_engine               = "redis"
#   db_version              = "6"
#   db_droplet_size         = "db-s-1vcpu-1gb"
#   db_node_count           = 1
#   db_tags                 = ["redis", "development", "managed_by_terraform"]
#   maintenance_window_day  = "saturday"
#   maintenance_window_hour = "11:00"
#
#   fw_rules = local.fw_rules
#
# }
#
resource "kubernetes_namespace" "postgres_namespace" {
  metadata {
    name = "postgres-operator"
    labels = {
      istio-injection      = "enabled"
      managed_by_terraform = "true"
    }
  }
}

module "k8s_postgres" {
  source    = "../modules/terraform-kubernetes-postgres"
  name      = "postgres-operator"
  namespace = kubernetes_namespace.postgres_namespace.id
}

resource "kubernetes_namespace" "redis_namespace" {
  metadata {
    name = "redis-operator"
    labels = {
      istio-injection      = "enabled"
      managed_by_terraform = "true"
    }
  }
}

module "k8s_redis" {
  source    = "../modules/terraform-kubernetes-redis"
  name      = "redis-operator"
  namespace = kubernetes_namespace.redis_namespace.id
}
