# Enable kv-v2 secret engine
resource "vault_mount" "kvv2" {
  path        = "secrets"
  type        = "kv-v2"
  description = "kv2 secrets storage"
}
