module "skupper" {
  source = "../modules/terraform-kubernetes-skupper"
  namespace = "openldap"
  cluster_name = local.cluster_name
  skupper_edge = "false"
}