variable "vpc_uuid" {
  description = "The ID of the VPC where the Kubernetes cluster will be located."
  type        = string
}
variable "db_cluster_name" {
  description = "Database Cluster name"
  type        = string
}

variable "region" {
  type        = string
  description = "The location of the cluster"
}

variable "db_engine" {
  type        = string
  description = "The engine of the cluster (pg, mysql, redis or mongodb)"
}

variable "db_version" {
  type        = string
  description = "The version for the database engine"
}

variable "db_droplet_size" {
  type        = string
  description = "Droplet size for DB nodes"
}

variable "replica_droplet_size" {
  type        = string
  description = "Droplet size for Read Replica nodes"
}

variable "db_node_count" {
  type        = number
  description = "Number of nodes on DB Cluster"
  default     = 1
}

variable "redis_eviction_policy" {
  type        = string
  description = "Eviction Policy for Redis Cluster (noeviction, allkeys_lru, allkeys_random, volatile_lru, volatile_random, or volatile_ttl)"
  default     = "allkeys_lru"
}

variable "mysql_sql_mode" {
  type        = string
  description = "A comma separated string specifying the SQL modes for a MySQL cluster."
  default     = "ANSI,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION,NO_ZERO_DATE,NO_ZERO_IN_DATE,STRICT_ALL_TABLES,ALLOW_INVALID_DATES"
}

variable "db_tags" {
  description = "The list of instance tags applied to the cluster."
  type        = list(any)
  default     = ["managed_by_terraform"]
}

variable "enable_read_replica" {
  type        = bool
  description = "Defines wheather or not to have a read replica for the DB"
  default     = false
}

variable "maintenance_window_day" {
  type        = string
  description = "The day of the week on which to apply maintenance updates."
  default     = "saturday"
}

variable "maintenance_window_hour" {
  type        = string
  description = "The hour in UTC at which maintenance updates will be applied in 24 hour format."
  default     = "02:00"
}

variable "databases" {
  description = "Databases to be created"
  type = map(object({
    mode          = string
    pool_size     = number
    database_user = string
  }))
  default = {}
}

variable "fw_rules" {
  description = "Firewall Rules to enforce private connections. Public access if empty."
  type = map(object({
    type  = string
    value = string
  }))
}
