variable "namespace" {
  type        = string
  description = "Namespace to deploy fluent-bit"
  default     = "kube-system"
}

variable "name" {
  type        = string
  description = "Name of the fluent-bit resource to deploy"
  default     = "fluent-bit"
}