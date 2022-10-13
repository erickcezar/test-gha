output "mongodb_uri" {
  description = "URI for connecting to mongodb"
  value       = "mongodb://${helm_release.mongodb.name}-headless.${helm_release.mongodb.namespace}.svc.cluster.local:27017/graylog?replicaSet=rs0"
}
