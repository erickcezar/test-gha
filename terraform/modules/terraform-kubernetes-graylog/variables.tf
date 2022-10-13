variable "namespace" {
  type        = string
  description = "Namespace to deploy graylog"
  default     = "graylog"
}

variable "chart_version" {
  type        = string
  description = "Graylog Chart version"
}

variable "replicas" {
  type        = number
  description = "The number of Graylog instances in the cluster. The chart will automatic create assign master to one of replicas"
  default     = 2
}

variable "heapSize" {
  type        = string
  description = "Override Java heap size. If this value empty, chart will allocate heapsize using -XX:+UseCGroupMemoryLimitForHeap"
  default     = ""
}

variable "storageClass" {
  type        = string
  description = "PVC Storage Class for graylog volumes"
  default     = "do-block-storage-retain"
}

variable "graylog_app_version" {
  type        = string
  description = "Grayog docker image tag"
}

variable "storage_size" {
  type        = string
  description = "PVC Storage Request for graylog volumes"
  default     = "10Gi"
}

variable "graylog_ingress" {
  type = object({
    host           = string
    path           = string
    cluster_issuer = string
    }
  )
  description = "ingress to be created for graylog"
  default     = null
}

variable "install_mongodb" {
  type        = bool
  description = "Wheather the helm chart also installs mongodb"
  default     = false
}

variable "mongodb_uri" {
  type        = string
  description = "Connection string for mongodb replicaset"
  default     = ""
}

variable "install_elasticsearch" {
  type        = bool
  description = "Wheather the helm chart also installs elasticsearch"
  default     = false
}
variable "elasticsearch_uri" {
  type        = string
  description = "Connection string for elasticsearch cluster"
}

variable "elasticsearch_version" {
  type        = number
  description = "Major version of elasticsearch"
  default     = 7
}
