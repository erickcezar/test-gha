module "skupper" {
  source = "../modules/terraform-kubernetes-skupper"
  namespace = "graylog"
  cluster_name = local.cluster_name
  skupper_edge = "true"
}