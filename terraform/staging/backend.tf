terraform {
  backend "remote" {
    organization = "marketcircle"

    workspaces {
      name = "staging"
    }
  }

}
