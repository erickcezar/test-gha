# Vault

* Deploys a vault server and injector in a kubernetes cluster
* Choose from Standalone or HA modes, by using the "ha_enabled" variable.
  * For standalone, only one statefulset replica is deployed
  * For HA mode, 3 replicas is deployed, by using podAntiAffinity. If labelSelector is used, it is possible to define dedicated hosts for vault (best practice)
* For this chart, the Raft storage is being used for persistence in HA mode.
* By default, Vault needs to be unsealed every time it reboots (even if one pod is rescheduled or restarted). Unsealing is a cumbersome process which can lead to undesired downtimes. If auto-unsealed is enabled, this module can use AWS KMS key to unseal vault whenever it needs.
* IMPORTANT: After bootstraping the cluster on either modes, it is necessary to initialize the vault. For that, "run kubectl -n vault exec vault-0 -- vault operator init"

example:

module "vault" {
  source                   = "../modules/terraform-kubernetes-vault"
  namespace                = kubernetes_namespace.vault.id
  storageClass             = "do-block-storage"
  storage_size             = "10Gi"
  ha_enabled               = true
  auto_unseal_enabled      = true
  VAULT_AWSKMS_SEAL_KEY_ID = "825c54f5-b1ea-465f-937f-ac56185da3b3"
  AWS_ACCESS_KEY_ID        = var.AWS_ACCESS_KEY_ID
  AWS_SECRET_ACCESS_KEY    = var.AWS_SECRET_ACCESS_KEY
  AWS_REGION               = var.AWS_REGION
  vault_ingress = {
    host           = "vault-dev.marketcircle.com"
    path           = "/"
    cluster_issuer = "letsencrypt"
  }
  tolerations = {
    key      = "taint_for_vault2",
    operator = "Exists",
    effect   = "NoExecute"
  }
  nodeSelector = "vault: 'true'"
}
