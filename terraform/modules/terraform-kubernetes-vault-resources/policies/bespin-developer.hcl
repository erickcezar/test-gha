path "secrets/*" {
  capabilities = ["list"]
}

path "secrets/data/bespin" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
