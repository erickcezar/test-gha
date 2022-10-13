terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.10.0"
    }
  }
  required_version = "~> 1.0.0"
}

provider "digitalocean" {
  token = var.do_token
}
