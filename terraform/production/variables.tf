variable "do_token" {
  description = "DigitalOcean token for terraform access"
  type        = string
  sensitive   = true
  default     = ""
}

variable "DO_SPACES_KEY" {
  type        = string
  description = "Digital Ocean Spaces key to access Spaces Buckets in Digital Ocean. Used for velero backups."
}

variable "DO_SPACES_SECRET" {
  type        = string
  description = "Digital Ocean Spaces secret to access Spaces Buckets in Digital Ocean. Used for velero backups."
}

variable "registry_server" {
  description = "URL of the private registry server for pulling images"
  type        = string
  default     = ""
}

variable "registry_username" {
  description = "Username for the registry server"
  type        = string
  sensitive   = true
  default     = ""
}

variable "registry_password" {
  description = "password for the registry server"
  type        = string
  sensitive   = true
  default     = ""
}

variable "externaldns_token" {
  description = "Token for External DNS manage the DNS provider"
  type        = string
  sensitive   = true
}

variable "externaldns_account_id" {
  description = "Account ID for External DNS manage the DNS provider DNSimple"
  type        = string
  sensitive   = true
}

variable "AWS_ACCESS_KEY_ID" {
  type        = string
  sensitive   = true
  description = "AWS access key ID for accessing KMS"
  default     = ""
}

variable "AWS_SECRET_ACCESS_KEY" {
  type        = string
  sensitive   = true
  description = "AWS secret access key ID for accessing KMS"
  default     = ""
}

variable "AWS_REGION" {
  type        = string
  description = "AWS region for S3 and KMS key"
  default     = ""
}

variable "github_token" {
  type        = string
  description = "github token"
}

variable "github_owner" {
  type        = string
  description = "github owner/organization"
}

variable "github_repository_name" {
  type        = string
  description = "github repository name"
}

variable "github_branch" {
  type        = string
  default     = "main"
  description = "branch name"
}

# variable "vault_terraform_approle_role_id" {
#   type        = string
#   default     = ""
#   description = "role_id for Terraform approle in Vault"
# }

# variable "vault_terraform_approle_secret_id" {
#   type        = string
#   default     = ""
#   description = "secret_id for Terraform approle in Vault"
#   sensitive   = true
# }

# variable "fastly_api_key" {
#   description = "Fastly API Key"
#   type        = string
#   sensitive   = true
# }

# variable "vault_mc_dev_cluster_issuer_pem_bundle" {
#   description = "PEM bundle for the issuer of the cluster"
#   type        = string
#   sensitive   = true
# }
