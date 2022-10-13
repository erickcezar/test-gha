resource "helm_release" "keycloak" {
  name              = var.name_keycloak
  chart             = "keycloak"
  repository        = "https://charts.bitnami.com/bitnami"
  version           = "9.3.6"
  namespace         = var.namespace
  create_namespace  = true
  dependency_update = true
  force_update      = false
  timeout           = 600
    values = [
    <<EOF
  httpRelativePath: "/auth/"
  ingress:
    tls: true
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt
      nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
      kubernetes.io/ingress.class: "nginx"
EOF
  ]

  set {
    name  = "image.tag"
    value = var.keycloak_image_tag
  }
  set {
    name  = "auth.adminUser"
    value = var.keycloak_admin_user
  }
  set {
    name  = "auth.adminPassword"
    value = var.keycloak_admin_pwd
  }
  set {
    name  = "auth.tls.enabled"
    value = var.tls_enabled_keycloak
  }
  set {
    name  = "replicaCount"
    value = var.replica_count_keycloak
  }
  set {
    name  = "metrics.enabled"
    value = var.keycloak_metrics
  }

  set {
    name = "service.type"
    value = var.keycloak_service_type
  }

  set {
    name = "ingress.enabled"
    value = var.keycloak_ingress
  }

  set {
    name = "ingress.hostname"
    value = var.keycloak_hostname
  }

  set {
    name = "ingress.path"
    value = var.keycloak_path
  }

}
