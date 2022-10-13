path "auth/kubernetes/role/*" {
  capabilities = ["create", "update", "read"]
}

path "token/lookup-self" {
  capabilities = ["read"]
}
