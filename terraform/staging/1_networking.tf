# Networking config
data "terraform_remote_state" "vpc" {
  backend = "remote"

  config = {
    organization = "marketcircle"
    workspaces = {
      name = "networking-staging-production"
    }
  }
}
