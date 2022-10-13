resource "digitalocean_database_cluster" "db_cluster" {
  name                 = var.db_cluster_name
  region               = var.region
  private_network_uuid = var.vpc_uuid
  engine               = var.db_engine
  version              = var.db_version
  size                 = var.db_droplet_size
  node_count           = var.db_node_count
  eviction_policy      = var.db_engine == "redis" ? var.redis_eviction_policy : null
  sql_mode             = var.db_engine == "mysql" ? var.mysql_sql_mode : null
  tags                 = var.db_tags

  maintenance_window {
    hour = var.maintenance_window_hour
    day  = var.maintenance_window_day
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }
}

# Wait for some time to allow DO to take automatic backup of new DB
# and allow the replica creation from it
resource "time_sleep" "wait_60_seconds" {
  depends_on = [digitalocean_database_cluster.db_cluster]

  create_duration = "60s"
}

resource "digitalocean_database_replica" "read-replica" {
  depends_on = [time_sleep.wait_60_seconds]
  count      = var.enable_read_replica ? 1 : 0
  cluster_id = digitalocean_database_cluster.db_cluster.id
  region     = var.region
  name       = "${digitalocean_database_cluster.db_cluster.name}-read-replica"
  size       = var.replica_droplet_size

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }

}

resource "digitalocean_database_db" "database" {
  for_each   = var.databases
  cluster_id = digitalocean_database_cluster.db_cluster.id
  name       = each.key
}

resource "digitalocean_database_user" "user" {
  for_each   = var.databases
  cluster_id = digitalocean_database_cluster.db_cluster.id
  name       = each.value.database_user
}


resource "digitalocean_database_connection_pool" "pool" {
  for_each   = var.databases
  cluster_id = digitalocean_database_cluster.db_cluster.id
  name       = "pool-${each.key}"
  mode       = each.value.mode
  size       = each.value.pool_size
  db_name    = digitalocean_database_db.database[each.key].name
  user       = digitalocean_database_user.user[each.key].name
}

resource "digitalocean_database_firewall" "firewall" {
  count      = length(var.fw_rules) == 0 ? 0 : 1
  cluster_id = digitalocean_database_cluster.db_cluster.id

  dynamic "rule" {

    for_each = var.fw_rules

    content {
      type  = rule.value.type
      value = rule.value.value
    }
  }
}
