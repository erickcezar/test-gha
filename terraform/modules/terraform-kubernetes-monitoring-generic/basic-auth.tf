locals {
  htpasswd_count = var.prometheus_ingress != null || var.alertmanager_ingress != null || var.grafana_ingress != null ? 1 : 0
}

resource "random_password" "password" {
  count   = local.htpasswd_count
  length  = 30
  special = false
}

resource "kubernetes_secret" "basic_auth_password" {
  count = local.htpasswd_count
  metadata {
    name      = "basic-auth-password"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }
  data = {
    username = "admin"
    password = random_password.password[0].result
  }
  type = "Opaque"
}

resource "kubernetes_secret" "basic_auth_htpasswd" {
  count = local.htpasswd_count
  metadata {
    name      = "basic-auth"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }
  data = {
    auth = "admin:${bcrypt(random_password.password[0].result, 5)}"
  }
  type = "Opaque"
  lifecycle {
    ignore_changes = [
      data,
    ]
  }
}
