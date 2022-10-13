# DaemonSet that adds and controls the route from DO
# to NeutralData servers trough the VPN Droplet

resource "kubernetes_namespace" "neutraldata" {

  metadata {
    labels = {
      name = "neutraldata"
      managed_by_terraform = "true"
    }
    name = "neutraldata"
  }
}

resource "kubernetes_daemonset" "neutraldata_route" {
  count      = var.neutraldata_route_enabled ? 1 : 0

  metadata {
    name      = "neutraldata-route"
    namespace = kubernetes_namespace.neutraldata.id
    labels = {
      app = "neutraldata-route"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "neutraldata-route"
      }
    }

    template {
      metadata {
        labels = {
          app = "neutraldata-route"
        }
      }   

      spec {
        host_network = true 
        container {
          image = var.neutraldata_route_image
          args  = var.neutraldata_route_args
          name  = "neutraldata-route"

          resources {
            limits = {
              cpu    = "200m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "25m"
              memory = "50Mi"
            }
          }

          port {
            container_port = 8000
            host_port      = 8000
            protocol       = "TCP"
          }
          security_context {
            capabilities {
              add = ["NET_ADMIN"]
            }
          }
        }
        image_pull_secrets {
          name = "github-registry"
        }
        dynamic "toleration" {
          for_each = var.neutraldata_tolerations
          content {
            key      = toleration.value["key"]
            operator = toleration.value["operator"]
            value    = toleration.value["value"]
            effect   = toleration.value["effect"]
          }
        }
      }
    }
  }
}

resource "kubernetes_secret" "github_registry" {
  count      = var.neutraldata_route_enabled ? 1 : 0

  metadata {
    name      = "github-registry"
    namespace = kubernetes_namespace.neutraldata.id
  }

  data = {
    ".dockerconfigjson" = <<DOCKER
{
  "auths": {
    "${var.registry_server}": {
      "auth": "${base64encode("${var.registry_username}:${var.registry_password}")}"
    }
  }
}
DOCKER
  }

  type = "kubernetes.io/dockerconfigjson"
}
