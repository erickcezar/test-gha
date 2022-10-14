terraform {
  backend "remote" {
    organization = "marketcircle"

    workspaces {
      name = "development-ams3"
    }
  }

}
