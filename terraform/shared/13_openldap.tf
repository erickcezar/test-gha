module "openldap" {
  source    = "../modules/terraform-kubernetes-openldap"
  namespace = "openldap"
  keycloak_admin_pwd = var.KEYCLOAK_ADM_PWD
  keycloak_ingress = true
  keycloak_hostname = "oauth-shared.marketcircle.dev"
  keycloak_path = "/"

  env = <<EOF
  LDAP_ORGANISATION: "Marketcircle"
EOF
}
