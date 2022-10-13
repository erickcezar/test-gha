#------------------------------------------------------------------------------#
# Vault external group
#------------------------------------------------------------------------------#

resource "vault_identity_oidc_role" "role" {
  count = length(var.groups)
  name = var.groups[count.index].group_name
  key  = var.vault_identity_oidc_key_name
}

resource "vault_identity_group" "group" {
  count = length(var.groups)
  name     = vault_identity_oidc_role.role[count.index].name
  type     = "external"
  policies = concat(["default"], var.groups[count.index].policies)
}

resource "vault_identity_group_alias" "reader_group_alias" {
  count = length(var.groups)
  name           = var.groups[count.index].group_name
  mount_accessor = var.external_accessor
  canonical_id   = vault_identity_group.group[count.index].id
}
