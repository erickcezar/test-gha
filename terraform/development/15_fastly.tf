module "fastly" {
  source = "../modules/terraform-fastly"
  fastly_api_key = var.fastly_api_key
}
