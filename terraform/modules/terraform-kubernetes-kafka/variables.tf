variable "name" {
  type        = string
  default     = "kafka"
  description = "Name of the chart deployment"
}

variable "namespaces_to_watch" {
  type        = list(string)
  description = "List of namespaces to monitor for kafka resources"
}

variable "toleration" {
  type = object({
    key      = string
    operator = string
    effect   = string
  })
  description = "Toleration settings for operator pods"
  default     = null
}

variable "node_selector" {
  type        = string
  description = "Node Selector for operator pods"
  default     = ""
}
