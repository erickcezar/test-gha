resource "helm_release" "openldap" {
  name              = var.name_openldap
  chart             = "openldap-stack-ha"
  repository        = "https://jp-gouin.github.io/helm-openldap"
  version           = "3.0.1"
  namespace         = var.namespace
  create_namespace  = true
  dependency_update = true
  force_update      = false
  timeout           = 600
  values = [
    <<EOF
global:
  ldapDomain: "marketcircle.com"
  adminPassword: ${var.openldap_admin_pwd}
  configPassword: ${var.openldap_config_pwd}
ltb-passwd:
  enabled : false
phpldapadmin:
  enabled: false
EOF
  ]
}