terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.10.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.2.1"
    }
  }
  required_version = "~> 1.0.0"
}
