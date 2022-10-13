# Enable PKI backend for issuing certificates from the MC DEV CA
resource "vault_mount" "mc-dev-cert-manager-cluster-issuer" {
  path        = "mc-dev-cert-manager-cluster-issuer"
  type        = "pki"
  description = "This PKI backend is used to generate certificate from the Marketcircle Dev CA Intermediate"
}

# resource "vault_pki_secret_backend_config_ca" "intermediate" {
#   depends_on = [vault_mount.mc-dev-cert-manager-cluster-issuer]
#   backend = vault_mount.mc-dev-cert-manager-cluster-issuer.path

#   pem_bundle = var.vault_mc_dev_cluster_issuer_pem_bundle

# }

resource "vault_pki_secret_backend_role" "cert-manager-cluster-issuer" {
  backend            = vault_mount.mc-dev-cert-manager-cluster-issuer.path
  name               = "cert-manager-cluster-issuer"
  allowed_domains    = ["marketcircle.dev", "*.marketcircle.dev"]
  allowed_uri_sans   = ["*.marketcircle.dev"]
  allow_localhost    = false
  enforce_hostnames  = false
  allow_bare_domains = false
  allow_subdomains   = true
  client_flag        = false
  server_flag        = true
  key_type           = "rsa"
  key_bits           = 2048
  key_usage          = ["DigitalSignature", "KeyAgreement", "KeyEncipherment"]
  organization       = ["Marketcircle Inc."]
  country            = ["CA"]
  province           = ["ON"]
}
