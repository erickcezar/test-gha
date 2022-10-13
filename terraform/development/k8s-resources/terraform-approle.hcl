path "auth/approle/login" {
  capabilities = ["create", "read"]
}

path "sys/auth/kubernetes" {
  capabilities = ["create", "update", "delete", "sudo"]
}

path "auth/kubernetes/*" {
  capabilities = ["read", "create", "update", "delete", "sudo"]
}

path "aws/*" {
  capabilities = ["read", "create", "update", "delete", "sudo"]
}


# List auth methods
path "sys/auth"
{
  capabilities = ["read"]
}

path "sys/renew/*" {
  policy = "write"
}

path "sys/mounts/*" {
  policy = "write"
}

path "sys/mounts" {
  capabilities = ["read"]
}

path "sys/mounts/secrets" {
  capabilities = ["create", "update", "delete", "read"]
}

path "auth/token/create" {
  capabilities = ["update"]
}

path "auth/token/renew/*" {
  policy = "write"
}

path "sys/policies/acl/*" {
  capabilities = ["read", "create", "update", "delete"]
}

path "mc-dev-cert-manager-cluster-issuer/roles/*" {
  policy = "write"
}