terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.10.0"
    }
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
    fastly = {
      source  = "fastly/fastly"
      version = ">= 0.41.0"
    }
    dnsimple = {
      source  = "dnsimple/dnsimple"
      version = "~> 0.11.1"
    }
  }
  required_version = "~> 1.0.0"
}

provider "digitalocean" {
  token             = var.do_token
  spaces_access_id  = var.DO_SPACES_KEY
  spaces_secret_key = var.DO_SPACES_SECRET
}

data "digitalocean_kubernetes_cluster" "cluster" {
  name = module.doks.name
}


provider "kubernetes" {
  experiments {
    manifest_resource = true
  }
  host                   = data.digitalocean_kubernetes_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate)
  token                  = data.digitalocean_kubernetes_cluster.cluster.kube_config[0].token
}

provider "kubectl" {
  host                   = data.digitalocean_kubernetes_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate)
  token                  = data.digitalocean_kubernetes_cluster.cluster.kube_config[0].token
  load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = data.digitalocean_kubernetes_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate)
    token                  = data.digitalocean_kubernetes_cluster.cluster.kube_config[0].token
  }
}
provider "aws" {
  region     = var.AWS_REGION
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
  default_tags {
    tags = {
      Owner = "Terraform"
    }
  }
}

# This provider depends on vault to be up and running in the cluster
# https://github.com/hashicorp/terraform/issues/2430

/*
provider "vault" {
  address = "https://vault.marketcircle.dev"
  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id   = var.vault_terraform_approle_role_id
      secret_id = var.vault_terraform_approle_secret_id
    }
  }
}
*/
# Configure the DNSimple provider
provider "dnsimple" {
  token   = var.externaldns_token
  account = var.externaldns_account_id
}