resource "kubernetes_secret" "aws-creds" {
  metadata {
    name      = "aws-creds"
    namespace = var.namespace
  }

  data = {
    AWS_ACCESS_KEY_ID     = var.AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY = var.AWS_SECRET_ACCESS_KEY
  }

  type = "kubernetes.io/opaque"
}
