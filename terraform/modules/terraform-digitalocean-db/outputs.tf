output "name" {
  value = digitalocean_database_cluster.db_cluster.name
}

output "public_uri" {
  value = digitalocean_database_cluster.db_cluster.uri
}

output "private_uri" {
  value = digitalocean_database_cluster.db_cluster.private_uri
}

output "db_user" {
  value = digitalocean_database_cluster.db_cluster.user
}

output "db_password" {
  value     = digitalocean_database_cluster.db_cluster.password
  sensitive = true
}

output "read_replica_name" {
  value = digitalocean_database_replica.read-replica[*].name
}

output "read_replica_uri" {
  value = digitalocean_database_replica.read-replica[*].uri
}

output "read_replica_private_uri" {
  value = digitalocean_database_replica.read-replica[*].private_uri
}

output "read_replica_db_user" {
  value = digitalocean_database_replica.read-replica[*].user
}

output "read_replica_db_password" {
  value     = digitalocean_database_replica.read-replica[*].password
  sensitive = true
}

output "database_pool_connection_public_uri" {
  value = { for k, v in digitalocean_database_connection_pool.pool : k => v.uri }
}

output "database_pool_connection_private_uri" {
  value = { for k, v in digitalocean_database_connection_pool.pool : k => v.private_uri }
}

output "database_pool_connection_public_host" {
  value = { for k, v in digitalocean_database_connection_pool.pool : k => v.host }
}

output "database_pool_connection_public_port" {
  value = { for k, v in digitalocean_database_connection_pool.pool : k => v.port }
}

output "database_pool_connection_private_host" {
  value = { for k, v in digitalocean_database_connection_pool.pool : k => v.private_host }
}

output "database_pool_connection_private_port" {
  value = { for k, v in digitalocean_database_connection_pool.pool : k => v.private_port }
}

output "database_pool_connection_password" {
  value     = { for k, v in digitalocean_database_connection_pool.pool : k => v.password }
  sensitive = true
}
