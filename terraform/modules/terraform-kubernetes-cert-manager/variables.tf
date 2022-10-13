variable "istio_injection" {
  type        = string
  description = "Do we enable or disable istio injection on the namespace"
  default     = "disabled"
}
