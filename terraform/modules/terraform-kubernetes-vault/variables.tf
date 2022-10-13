variable "namespace" {
  type        = string
  description = "Namespace to deploy vault"
  default     = "vault"
}

variable "storageClass" {
  type        = string
  description = "PVC Storage Class for Vault volumes"
  default     = "do-block-storage-retain"
}

variable "vault_app_version" {
  type        = string
  description = "Vault docker image tag"
}

variable "storage_size" {
  type        = string
  description = "PVC Storage Request for Vault volumes"
  default     = "10Gi"
}

variable "ha_enabled" {
  type        = bool
  description = "Whether do use vault in HA mode or Standalone mode"
  default     = true
}

variable "auto_unseal_enabled" {
  type        = bool
  description = "Whether do use auto unseal feature by using AWS KMS"
  default     = false
}

variable "AWS_ACCESS_KEY_ID" {
  type        = string
  sensitive   = true
  description = "AWS access key ID for accessing KMS"
}

variable "AWS_SECRET_ACCESS_KEY" {
  type        = string
  sensitive   = true
  description = "AWS secret access key ID for accessing KMS"
}

variable "AWS_REGION" {
  type        = string
  description = "AWS region for KMS key"
}

variable "VAULT_AWSKMS_SEAL_KEY_ID" {
  type        = string
  sensitive   = true
  description = "AWS KMS key ID for auto unseal"
}

variable "vault_ingress" {
  type = object({
    host           = string
    path           = string
    cluster_issuer = string
    }
  )
  description = "ingress to be created for vault"
  default     = null
}

variable "tolerations" {
  type = object({
    key      = string
    operator = string
    effect   = string
  })
  description = "Toleration Settings for server pods"
  default     = null
}

variable "nodeSelector" {
  type        = string
  description = "Node Selector for server pods"
  default     = ""
}
