terraform {
   backend "remote" {
    organization = "marketcircle"

    workspaces {
      name = "networking-staging-production"
    }
  }
}
