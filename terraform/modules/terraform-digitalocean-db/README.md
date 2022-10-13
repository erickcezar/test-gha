#  DigitalOcean Managed Databases

## Features

* Creates a Database Cluster on DigitalOcean for the following engines:
  - Postgres
  - MySQL
  - Redis
  - MongoDB
* Creates a Read Replica (if enabled)
* Creates databases and users
* Creates a Connetion pool for each Database
* Creates firewall rules for private access only.

For connection pool, the sum of all "pool_size" variable should be less than 25 x 'GB of Total RAM'

## Example usage
```

locals {
  fw_rules = {
    "rule01" = {
      type  = "k8s"
      value = module.doks.id
    }
    "rule02" = {
      type  = "ip_addr"
      value = "10.8.0.0/24"
    }
  }
}

# Postgres example
module "managed_postgres" {
  source = "../../../../terraform/terraform-digitalocean-db"

  db_cluster_name         = "dev-postgres"
  region                  = local.region
  vpc_uuid                = digitalocean_vpc.development.id
  db_engine               = "pg"
  db_version              = "11"
  db_droplet_size         = "db-s-1vcpu-1gb"
  db_node_count           = 1
  db_tags                 = ["postgres", "development", "managed_by_terraform"]
  maintenance_window_day  = "saturday"
  maintenance_window_hour = "11:00"

  enable_read_replica  = true
  replica_droplet_size = "db-s-1vcpu-1gb"

  databases = {
    "db1" = {
      mode          = "transaction"
      pool_size          = 10
      database_user = "user1"
    }
    "db2" = {
      mode          = "session"
      pool_size          = 10
      database_user = "user2"
    }
  }

  fw_rules = local.fw_rules

}

#Redis Example
module "managed_redis" {
  source = "../../../../terraform/terraform-digitalocean-db"

  db_cluster_name         = "dev-redis"
  region                  = local.region
  vpc_uuid                = digitalocean_vpc.development.id
  db_engine               = "redis"
  db_version              = "6"
  db_droplet_size         = "db-s-1vcpu-1gb"
  db_node_count           = 1
  db_tags                 = ["redis", "development", "managed_by_terraform"]
  maintenance_window_day  = "saturday"
  maintenance_window_hour = "11:00"

  fw_rules = local.fw_rules

}
```

* Bugs and Limitations
The value for maintenance_window_hour is in hh:mm format. However, DO seems to store it in hh:mm:ss format, so every plan/apply will show a drift because of the 'seconds' 
