variable "namespace" {
  type        = string
  description = "Namespace to deploy redis"
  default     = "redis-operator"
}

variable "name" {
  type        = string
  description = "Name of the Redis Operator instance"
  default     = "redis-operator"
}
