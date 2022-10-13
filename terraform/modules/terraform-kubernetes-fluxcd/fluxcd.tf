provider "github" {
  owner = var.github_owner
  token = var.github_token
}

# SSH
locals {
  known_hosts = "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
}

# Create a key pair to be defined as Deploy Key in GitHub
resource "tls_private_key" "main" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

# resource "gpg_private_key" "gpg_key" {
#   name       = "FluxCD tor1-development"
#   email      = "tor1-development@marketcircle.com"
# }
#
# resource "kubernetes_secret" "gpg_key" {
#   metadata {
#     name = "flux-gpg-signing-key"
#     namespace = "flux-system"
#   }
#
#   data = {
#     "flux.asc" = gpg_private_key.gpg_key.private_key
#   }
# }

# Flux
data "flux_install" "main" {
  target_path = var.target_path
  version     = var.flux_version
}

data "flux_sync" "main" {
  target_path = var.target_path
  url         = "ssh://git@github.com/${var.github_owner}/${var.repository_name}.git"
  branch      = var.branch
}

# Kubernetes
resource "kubernetes_namespace" "flux_system" {
  metadata {
    name = "flux-system"
    labels = {
      managed_by_terraform = "true"
    }
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
    ]
  }
}

data "kubectl_file_documents" "install" {
  content = data.flux_install.main.content
}

data "kubectl_file_documents" "sync" {
  content = data.flux_sync.main.content
}

locals {
  install = [for v in data.kubectl_file_documents.install.documents : {
    data : yamldecode(v)
    content : v
    }
  ]
  sync = [for v in data.kubectl_file_documents.sync.documents : {
    data : yamldecode(v)
    content : v
    }
  ]
}

resource "kubectl_manifest" "install" {
  for_each   = { for v in local.install : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubernetes_namespace.flux_system]
  yaml_body  = each.value
}

resource "kubectl_manifest" "sync" {
  for_each   = { for v in local.sync : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubernetes_namespace.flux_system]
  yaml_body  = each.value
}

resource "kubernetes_secret" "main" {
  depends_on = [kubectl_manifest.install]

  metadata {
    name      = data.flux_sync.main.secret
    namespace = data.flux_sync.main.namespace
  }

  data = {
    identity       = tls_private_key.main.private_key_pem
    "identity.pub" = tls_private_key.main.public_key_pem
    known_hosts    = local.known_hosts
  }
}

data "github_repository" "main" {
  name = var.repository_name
}

resource "github_repository_deploy_key" "main" {
  title      = "flux-${var.environment}"
  repository = data.github_repository.main.name
  key        = tls_private_key.main.public_key_openssh
  read_only  = true
}

resource "github_repository_file" "install" {
  repository     = data.github_repository.main.name
  file           = data.flux_install.main.path
  content        = data.flux_install.main.content
  branch         = var.branch
  commit_message = "Managed by Terraform"
  commit_author  = "Terraform User"
  commit_email   = "terraform@marketcircle.com"
}

resource "github_repository_file" "sync" {
  repository     = data.github_repository.main.name
  file           = data.flux_sync.main.path
  content        = data.flux_sync.main.content
  branch         = var.branch
  commit_message = "Managed by Terraform"
  commit_author  = "Terraform User"
  commit_email   = "terraform@marketcircle.com"
}

resource "github_repository_file" "kustomize" {
  repository     = data.github_repository.main.name
  file           = data.flux_sync.main.kustomize_path
  content        = data.flux_sync.main.kustomize_content
  branch         = var.branch
  commit_message = "Managed by Terraform"
  commit_author  = "Terraform User"
  commit_email   = "terraform@marketcircle.com"
}

resource "kubectl_manifest" "podmonitor" {
  yaml_body = <<EOF
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: flux-system
  namespace: flux-system
  labels:
    app.kubernetes.io/part-of: flux
    app.kubernetes.io/component: monitoring
    release: prometheus
spec:
  namespaceSelector:
    matchNames:
      - flux-system
  selector:
    matchExpressions:
      - key: app
        operator: In
        values:
          - helm-controller
          - source-controller
          - kustomize-controller
          - notification-controller
          - image-automation-controller
          - image-reflector-controller
  podMetricsEndpoints:
    - port: http-prom
EOF
}

resource "github_repository_file" "infrastructure-kustomization" {
  repository     = data.github_repository.main.name
  file           = "${var.target_path}/infrastructure.yaml"
  content        = <<EOF
---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta1
kind: Kustomization
metadata:
  name: infrastructure
  namespace: flux-system
spec:
  interval: 10m0s
  sourceRef:
    kind: GitRepository
    name: flux-system
  path: ./kubernetes/infrastructure/${var.cluster_name}
  prune: true
  validation: client
EOF
  branch         = var.branch
  commit_message = "Managed by Terraform"
  commit_author  = "Terraform User"
  commit_email   = "terraform@marketcircle.com"
}

resource "github_repository_file" "apps-kustomization" {
  repository     = data.github_repository.main.name
  file           = "${var.target_path}/apps.yaml"
  content        = <<EOF
---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta1
kind: Kustomization
metadata:
  name: apps
  namespace: flux-system
spec:
  interval: 10m0s
  sourceRef:
    kind: GitRepository
    name: flux-system
  path: ./kubernetes/apps/${var.cluster_name}
  prune: true
  validation: client
EOF
  branch         = var.branch
  commit_message = "Managed by Terraform"
  commit_author  = "Terraform User"
  commit_email   = "terraform@marketcircle.com"
}
