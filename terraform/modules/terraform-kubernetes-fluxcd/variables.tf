variable "github_owner" {
  type        = string
  description = "github owner/organization"
}

variable "github_token" {
  type        = string
  description = "github token"
}

variable "repository_name" {
  type        = string
  description = "github repository name"
}

variable "repository_visibility" {
  type        = string
  default     = "private"
  description = "How visible is the github repo"
}

variable "branch" {
  type        = string
  default     = "main"
  description = "branch name"
}

variable "target_path" {
  type        = string
  description = "flux sync target path"
}

variable "environment" {
  type        = string
  description = "cluster environment"
}

variable "flux_version" {
  type        = string
  description = "version of FluxCD to install"
  default     = "v0.26.0"
}

variable "cluster_name" {
  type = string
  description = "cluster name"
}
