variable "vpc_uuid" {
  description = "The ID of the VPC where the Kubernetes cluster will be located."
  type        = string
}
variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "region" {
  type        = string
  description = "The location of the cluster"
}

variable "tags" {
  description = "The list of instance tags applied to the cluster."
  type        = list(any)
  default     = ["kubernetes"]
}

variable "kubernetes_version" {
  type        = string
  description = "The Kubernetes version"
}

variable "kubernetes_version_latest" {
  type        = bool
  description = "Whether to install the latest of minor version"
}

variable "main_nodepool_name" {
  type        = string
  description = "The name of the main nodepool."
  default = "main"
}

variable "size" {
  type        = string
  description = "The slug identifier for the type of Droplet to be used as workers in the node pool."
}

variable "max_nodes" {
  default     = 5
  type        = string
  description = "Autoscaling maximum node capacity"
}

variable "node_count" {
  type        = number
  description = "The number of Droplet instances in the node pool. Not used if autoscale is enabled"
  default     = 1
}

variable "min_nodes" {
  default     = 1
  type        = string
  description = "Autoscaling Minimum node capacity"
}

variable "auto_scale" {
  description = "Enable cluster autoscaling"
  type        = bool

}

variable "auto_upgrade" {
  type        = bool
  description = "Whether the cluster will be automatically upgraded"
  default     = false
}

variable "maintenance_policy_start_time" {
  type        = string
  description = "The start time in UTC of the maintenance window policy in 24-hour clock format / HH:MM notation"
  default     = "03:00"
}


variable "maintenance_policy_day" {
  type        = string
  description = "The day of the maintenance window policy"
  default     = "sunday"
}

variable "node_labels" {
  description = "List of Kubernetes labels to apply to the nodes"
  type        = map(any)
  default = {
    "service" = "kubernetes"
  }
}

variable "node_tags" {
  description = "The list of instance tags applied to all nodes."
  type        = list(any)
  default     = ["kubernetes"]
}

#############################################################################
# Addons node pool

variable "node_pools" {
  description = "Addons node pools"
  type = map(object({
    size        = string
    node_count  = number
    auto_scale  = bool
    min_nodes   = number
    max_nodes   = number
    node_tags   = list(string)
    node_labels = map(string)
    node_taints = list(map(string))
  }))
  default = {}
}
