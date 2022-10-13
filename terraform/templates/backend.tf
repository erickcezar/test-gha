terraform {
  backend "remote" {
    organization = "marketcircle"

    workspaces {
      name = "WORKSPACE_NAME"
    }
  }

}
