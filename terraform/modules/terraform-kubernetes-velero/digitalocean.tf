resource "digitalocean_spaces_bucket" "bucket" {
  name   = var.digitalocean_bucket_name
  region = var.digitalocean_bucket_region

  lifecycle_rule {
    id      = "backups-lifecycle-rule"
    enabled = var.digitalocean_bucket_lifecycle_enabled
    expiration {
      days = var.digitalocean_bucket_lifecycle_expiration_days
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "kubernetes_secret" "digitalocean-spaces-credentials" {
  metadata {
    name      = "digitalocean-spaces-credentials"
    namespace = var.velero_namespace
  }

  data = {
    DIGITALOCEAN_TOKEN = var.do_token
    cloud              = <<EOF
[default]
aws_access_key_id=${var.do_spaces_key}
aws_secret_access_key=${var.do_spaces_secret}
EOF
  }
}


resource "kubectl_manifest" "digitalocean_backupstoragelocation" {
  depends_on = [helm_release.velero]
  yaml_body = <<YAML
apiVersion: velero.io/v1
kind: BackupStorageLocation
metadata:
  name: digitalocean
  namespace: ${var.velero_namespace}
spec:
  accessMode: ReadWrite
  config:
    region: ${var.digitalocean_bucket_region}
    s3Url: https://${var.digitalocean_bucket_region}.digitaloceanspaces.com
  credential:
    key: cloud
    name: ${kubernetes_secret.digitalocean-spaces-credentials.metadata[0].name}
  default: true
  objectStorage:
    bucket: ${digitalocean_spaces_bucket.bucket.name}
  provider: aws
YAML
}

resource "kubectl_manifest" "digitalocean_snapshotstoragelocation" {
  depends_on = [helm_release.velero]
  yaml_body = <<YAML
apiVersion: velero.io/v1
kind: VolumeSnapshotLocation
metadata:
  name: digitalocean
  namespace: ${var.velero_namespace}
spec:
  config:
    region: ${var.digitalocean_bucket_region}
  provider: digitalocean.com/velero
YAML
}

resource "kubectl_manifest" "digitalocean_schedule" {
  depends_on = [helm_release.velero]
  yaml_body = <<YAML
apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: daily-digitalocean-backups
  namespace: ${var.velero_namespace}
spec:
  schedule: ${var.digitalocean_velero_schedule}
  template:
    includedNamespaces:
    - '*'
    includedResources:
    - '*'
    snapshotVolumes: ${var.digitalocean_snapshots_enabled}
    storageLocation: digitalocean
    ttl: 240h0m0s
    volumeSnapshotLocations:
    - digitalocean
  useOwnerReferencesInBackup: false
YAML
}
