module "fluxcd" {
  source                = "../modules/terraform-kubernetes-fluxcd"
  github_owner          = var.github_owner
  github_token          = var.github_token
  repository_name       = var.github_repository_name
  repository_visibility = "private"
  branch                = var.github_branch
  target_path           = "kubernetes/clusters/${local.region}-${local.environment}"
  cluster_name          = local.cluster_name
  environment           = local.environment
  flux_version          = "v0.31.5"
}
