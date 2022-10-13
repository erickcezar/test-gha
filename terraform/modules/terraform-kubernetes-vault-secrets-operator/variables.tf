variable "namespace" {
  type        = string
  description = "Namespace to deploy vault-secrets-operator"
  default     = "vault"
}

variable "name" {
  type        = string
  description = "Name of the Vault Secrets Operator resources"
  default     = "vault-secrets-operator"
}