variable "namespace" {
  description = "Namespace to deploy chart in"
  type        = string
}

variable "name_openldap" {
  description = "Name of the helm deployment"
  type        = string
  default     = "openldap"
}
variable "name_keycloak" {
  description = "Name of the helm deployment"
  type        = string
  default     = "keycloak"
}

variable "keycloak_image_tag" {
  description = "Tag version of the keycloak image"
  type        = string
  default     = "18.0.2-debian-11-r0"
}

variable "openldap_image_tag" {
  description = "Tag version of the openldap image"
  type        = string
  default     = "1.2.2"
}

variable "tls_enabled_openldap" {
  type    = bool
  default = false
}

variable "tls_enabled_keycloak" {
  type    = bool
  default = false
}

variable "tls_secret" {
  type    = string
  default = ""
}

variable "tls_CA_enabled" {
  type    = bool
  default = false
}

variable "tls_CA_secret" {
  type    = string
  default = ""
}

variable "env" {
  description = "Environment variables to pass down directly to openldap"
  type        = string
  default     = ""
}

variable "replica_count_openldap" {
  type    = number
  default = 1
}

variable "replica_count_keycloak" {
  type    = number
  default = 1
}

variable "persistence_enabled" {
  type    = bool
  default = true
}

variable "persistence_storageclass" {
  type    = string
  default = ""
}

variable "persistence_access_mode" {
  type    = string
  default = "ReadWriteOnce"
}

variable "persistence_size" {
  type    = string
  default = "8Gi"
}

variable "persistence_existing_claim" {
  type    = string
  default = ""
}

variable "keycloak_admin_user" {
  type    = string
  default = "admin"
}

variable "keycloak_admin_pwd" {
  type    = string
  sensitive = true
}

variable "keycloak_ingress" {
  type = bool
  default = false
}

variable "keycloak_metrics" {
  type    = bool
  default = false
}

variable "keycloak_service_type" {
  type = string
  default = "ClusterIP"
}

variable "keycloak_hostname" {
  type    = string
}

variable "keycloak_path" {
  type    = string
}

variable "openldap_admin_pwd" {
  type    = string
  default = ""
  sensitive = true
}

variable "openldap_config_pwd" {
  type    = string
  default = ""
  sensitive = true
}