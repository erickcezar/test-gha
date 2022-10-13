# module "consul" {
#   source = "../modules/terraform-kubernetes-consul"

#   enable_client              = true
#   client_join_ips            = ["10.137.32.83","10.137.160.219", "10.137.16.180"]
#   client_expose_gossip_ports = true
#   client_extra_config        = "{\"node_meta\": {\"kubernetes-cluster\": \"tor1-development\"}}"

#   client_tolerations = <<EOF
#   - operator: Exists
# EOF

#   sync_catalog = true
#   sync_catalog_to_consul = true
#   sync_catalog_to_k8s = false
#   sync_catalog_k8s_allow_namespaces = ["kafka"]
#   sync_catalog_consul_prefix = "tor1-development-"
#   sync_catalog_k8s_tag = "tor1-development"
#   gossip_encryption_key = var.gossip_encryption_key
# }
