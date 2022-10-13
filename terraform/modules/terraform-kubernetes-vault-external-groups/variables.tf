

variable "groups" {
  type = list(object({
    group_name = string
    policies = list(string)
  }))
}

variable "vault_identity_oidc_key_name" {
  type = string
}

variable "external_accessor" {}
