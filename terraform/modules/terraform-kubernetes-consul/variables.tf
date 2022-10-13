variable "chart_version" {
  type        = string
  description = "Chart version to use"
  default     = "0.45.0"
}

variable "consul_version" {
  type        = string
  description = "Consul version to use"
  default     = "1.10.0"
}

variable "consul_datacenter" {
  type        = string
  description = "Consul datacenter to use"
  default     = "tor1"
}

variable "enable_server" {
  type = bool
  description = "Determine whether the chart will install all the resources necessary for a Consul server cluster."
  default = false
}

variable "enable_client" {
  type = bool
  description = "Determine whether will install all the resources necessary for a Consul client on every Kubernetes node."
  default = false
}

variable "client_join_ips" {
  type = list(string)
  description = "List of IP addresses to join the cluster."
}

variable "client_expose_gossip_ports" {
  type = bool
  description = "Determine whether to expose the Consul Gossip ports on the Kubernetes nodes."
}

variable "client_extra_config" {
  type = string
  description = "Extra configuration to pass to the Consul client."
}

variable "client_tolerations" {
  type = string
  description = "List of tolerations to apply to the Consul client pods."
}

variable "sync_catalog" {
  type = bool
  description = "Determine whether to sync the Consul catalog."
  default = false
}

variable "sync_catalog_to_consul" {
  type = bool
  description = "Determine whether to sync the K8s Service to Consul."
  default = true
}

variable "sync_catalog_to_k8s" {
  type = bool
  description = "Determine whether to sync the Consul catalog to k8s."
  default = false
}

variable "sync_catalog_k8s_allow_namespaces" {
  type = list(string)
  description = "List of namespaces to allow syncing the k8s services from."
  default = []
}

variable "sync_catalog_consul_prefix" {
  type = string
  description = "Prefix to use for the Consul catalog."
  default = "k8s"
}

variable "sync_catalog_k8s_tag" {
  type = string
  description = "Tag to use for the Consul catalog."
  default = "k8s"
}

variable "gossip_encryption_key" {
  type = string
  description = "Gossip encryption key to use."
  sensitive = true
}
