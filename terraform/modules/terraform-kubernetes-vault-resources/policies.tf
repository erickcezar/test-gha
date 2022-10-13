resource "vault_policy" "cert-manager" {
  name   = "cert-manager"
  policy = file("${path.module}/policies/cert-manager.hcl")
}

resource "vault_policy" "vault-secrets-operator" {
  name   = "vault-secrets-operator"
  policy = file("${path.module}/policies/vault-secrets-operator.hcl")
}

resource "vault_policy" "bespin" {
  name   = "bespin"
  policy = file("${path.module}/policies/bespin.hcl")
}

resource "vault_policy" "theron" {
  name   = "theron"
  policy = file("${path.module}/policies/theron.hcl")
}

resource "vault_policy" "daylite-api" {
  name   = "daylite-api"
  policy = file("${path.module}/policies/daylite-api.hcl")
}

resource "vault_policy" "yavin-server" {
  name   = "yavin-server"
  policy = file("${path.module}/policies/yavin-server.hcl")
}

resource "vault_policy" "tatooine" {
  name   = "tatooine"
  policy = file("${path.module}/policies/tatooine.hcl")
}

resource "vault_policy" "kashyyyk" {
  name   = "kashyyyk"
  policy = file("${path.module}/policies/kashyyyk.hcl")
}

resource "vault_policy" "deployer" {
  name   = "deployer"
  policy = file("${path.module}/policies/deployer.hcl")
}

resource "vault_policy" "admin" {
  name   = "admin"
  policy = file("${path.module}/policies/admin.hcl") 
}

resource "vault_policy" "bespin-developer" {
  name   = "bespin-developer"
  policy = file("${path.module}/policies/bespin-developer.hcl")
}

resource "vault_policy" "serverenvironments" {
  name   = "serverenvironments"
  policy = file("${path.module}/policies/serverenvironments.hcl")
}
