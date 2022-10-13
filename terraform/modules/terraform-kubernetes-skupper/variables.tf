variable "namespace" {
  type        = string
  description = "Namespace to deploy skupper"
  default     = ""
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "skupper_edge" {
  type        = string
  description = "Enable LB. False to create LB and true to internal network"
  default     = ""
}