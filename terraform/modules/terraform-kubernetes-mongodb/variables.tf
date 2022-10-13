variable "namespace" {
  type        = string
  description = "Namespace to deploy mongodb"
}

variable "name" {
  type        = string
  description = "Name of the Mongodb Replicaset"
}

variable "chart_version" {
  type        = string
  description = "MongoDB Chart version"
}

variable "architecture" {
  type        = string
  description = "Mongodb architecture. Allowed values: standalone or replicaset"
  default     = "standalone"
}

variable "storageClass" {
  type        = string
  description = "PVC Storage Class for Redis volume"
  default     = "do-block-storage"
}

variable "replica_count" {
  type        = number
  description = "Number of Mongodb replicas to deploy"
  default     = 3
}

variable "storage_size" {
  type        = string
  description = "PVC Storage Request for Mongodb volume"
  default     = "8Gi"
}

variable "enable_metrics" {
  type        = bool
  description = "Start a sidecar prometheus exporter to expose Redis™ metrics"
  default     = true
}

variable "enable_auth" {
  type        = bool
  description = "Disable or enable authentication on MongoDB"
  default     = false
}
