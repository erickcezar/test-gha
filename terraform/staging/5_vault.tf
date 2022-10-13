resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
    labels = {
      istio-injection      = "enabled"
      managed_by_terraform = "true"
    }
  }
}

module "vault" {
  source                   = "../modules/terraform-kubernetes-vault"
  namespace                = kubernetes_namespace.vault.id
  vault_app_version        = null
  storageClass             = "do-block-storage-retain"
  storage_size             = "10Gi"
  ha_enabled               = true
  auto_unseal_enabled      = true
  VAULT_AWSKMS_SEAL_KEY_ID = "07b5ea20-8cc9-465a-a04d-3184812fc229"
  AWS_ACCESS_KEY_ID        = var.AWS_ACCESS_KEY_ID
  AWS_SECRET_ACCESS_KEY    = var.AWS_SECRET_ACCESS_KEY
  AWS_REGION               = var.AWS_REGION
  vault_ingress = {
    host           = "vault.staging.marketcircle.net"
    path           = "/"
    cluster_issuer = "letsencrypt"
  }
  tolerations = {
    key      = "dedicated",
    operator = "Exists",
    effect   = "NoSchedule"
  }
  nodeSelector = "dedicated: 'vault'"
}
