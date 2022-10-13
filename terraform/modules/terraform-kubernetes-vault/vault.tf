resource "helm_release" "vault" {
  name              = "vault"
  chart             = "vault"
  repository        = "https://helm.releases.hashicorp.com"
  version           = "0.22.0"
  namespace         = var.namespace
  dependency_update = true
  force_update      = false
  values = [
    file("${path.module}/values/vault-values.yaml"),
    <<EOT
server:
%{if var.vault_app_version != null}
  image:
    tag: ${var.vault_app_version}
%{endif}
%{if var.vault_ingress != null}
  ingress:
    enabled: true
    annotations:
      cert-manager.io/cluster-issuer: ${var.vault_ingress.cluster_issuer}
      nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
      kubernetes.io/ingress.class: "nginx"
    hosts:
       - host: ${var.vault_ingress.host}
         paths:
         - ${var.vault_ingress.path}
    tls:
    - secretName: vault-tls
      hosts:
      - ${var.vault_ingress.host}
%{endif}
%{if var.tolerations != null}
  tolerations:
  - key: "${var.tolerations.key}"
    operator: "${var.tolerations.operator}"
    effect: "${var.tolerations.effect}"
%{endif}
%{if var.nodeSelector != null}
  nodeSelector:
    ${var.nodeSelector}
%{endif}
EOT
  ]
  set {
    name  = "server.auditStorage.storageClass"
    value = var.storageClass
  }
  set {
    name  = "server.auditStorage.size"
    value = var.storage_size
  }
  set {
    name  = "server.dataStorage.storageClass"
    value = var.storageClass
  }
  set {
    name  = "server.dataStorage.size"
    value = var.storage_size
  }
  set {
    name  = "server.ha.enabled"
    value = var.ha_enabled ? "true" : "false"
  }
  set {
    name  = "server.standalone.enabled"
    value = var.ha_enabled ? "false" : "true"
  }
  set {
    name  = "server.extraEnvironmentVars.VAULT_SEAL_TYPE"
    value = var.auto_unseal_enabled ? "awskms" : "shamir"
  }
  set {
    name  = "server.extraEnvironmentVars.VAULT_AWSKMS_SEAL_KEY_ID"
    value = var.auto_unseal_enabled ? var.VAULT_AWSKMS_SEAL_KEY_ID : ""
  }
  set {
    name  = "server.extraEnvironmentVars.AWS_REGION"
    value = var.auto_unseal_enabled ? var.AWS_REGION : ""
  }
}
