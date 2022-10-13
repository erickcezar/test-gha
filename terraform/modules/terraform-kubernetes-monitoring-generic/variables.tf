variable "cluster_name" {
  type        = string
  description = "Kubernetes cluster name"
}

variable "istio_injection" {
  type        = string
  description = "Do we enable or disable istio injection on the namespace"
  default     = "enabled"
}

variable "namespace" {
  type        = string
  description = "Namespace to deploy monitoring tools to."
  default     = "monitoring"
}


variable "prometheus_replica_count" {
  type        = number
  description = "Number of prometheus server replicaCount"
  default     = 2
}

variable "alertmanager_persistent_volume_size" {
  type        = string
  description = "Prometheus server persistent volume size"
  default     = "25Gi"
}

variable "prometheus_persistent_volume_size" {
  type        = string
  description = "Prometheus server persistent volume size"
  default     = "25Gi"
}

variable "prometheus_storageclass" {
  type        = string
  description = "Prometheus server storageclass"
  default     = "default"
}

variable "alertmanager_storageclass" {
  type        = string
  description = "Alertmanager server storageclass"
  default     = "default"
}

variable "grafana_storageclass" {
  type        = string
  description = "grafana server storageclass"
  default     = "default"
}

variable "prometheus_retention_length" {
  type        = string
  description = "Prometheus retention length"
  default     = "30d"
}

variable "slack_alerts_url" {
  type        = string
  description = "The slack webhook URL to send alerts to."
}

variable "slack_alerts_channel" {
  type        = string
  description = "Which Slack channel to send alerts to: #company-channel"
}


variable "prometheus_alerts_rules" {
  type        = string
  description = "Prometheus alert rules"
  default     = ""
}

variable "prometheus_alerts_rules_extra" {
  type        = string
  description = "Alert rules to manage manually by the team"
  default     = ""
}

variable "pagerduty_service_key" {
  type        = string
  description = "which PagerDuty service key to send alerts to: servicekey"
  default     = ""
}

variable "prometheus_ingress" {
  type = object({
    host           = string
    path           = string
    cluster_issuer = string
    }
  )
  description = "ingress to be created for prometheus thanos"
  default     = null
}

variable "alertmanager_ingress" {
  type = object({
    host           = string
    path           = string
    cluster_issuer = string
    }
  )
  description = "ingress to be created for alertmanager"
  default     = null
}

variable "grafana_ingress" {
  type = object({
    host           = string
    path           = string
    cluster_issuer = string
    }
  )
  description = "ingress to be created for grafana"
  default     = null
}

variable "grafana_client_secret" {
  type    = string
  default = ""
  sensitive = true
}