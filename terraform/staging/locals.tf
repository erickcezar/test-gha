# Main infrastucture config
locals {
  region      = "tor1"
  environment = "staging"
  vpc_uuid    = data.terraform_remote_state.vpc.outputs.vpc_uuid
}