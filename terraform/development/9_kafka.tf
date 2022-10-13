module "kafka" {
  source              = "../modules/terraform-kubernetes-kafka"
  name                = "kafka"
  namespaces_to_watch = ["kafka"]
}
