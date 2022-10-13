module "s3-bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "2.11.1"

  bucket        = var.aws_bucket_name
  acl           = "private"
  force_destroy = false

  attach_policy = false

  attach_deny_insecure_transport_policy = var.aws_bucket_s3_force_ssl

  versioning = {
    enabled = var.aws_bucket_versioning_enabled
  }

  logging = var.aws_bucket_logging

  lifecycle_rule = var.aws_bucket_lifecycle_rule

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  # S3 bucket-level Public Access Block configuration
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # S3 Bucket Ownership Controls
  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"
}

resource "helm_release" "velero" {
  name       = "velero"
  repository = "https://vmware-tanzu.github.io/helm-charts"
  chart      = "velero"
  version    = "2.31.8"
  namespace  = var.velero_namespace
  wait       = true
  values = [
    file("${path.module}/values/velero-values-aws.yaml"),
    <<EOT
credentials:
  secretContents:
     cloud: |
       [default]
       aws_access_key_id=${var.AWS_ACCESS_KEY_ID}
       aws_secret_access_key=${var.AWS_SECRET_ACCESS_KEY}
  extraEnvVars:
     DIGITALOCEAN_TOKEN: ${var.do_token}
EOT
  ]
  set {
    name  = "configuration.backupStorageLocation.bucket"
    value = module.s3-bucket.s3_bucket_id
  }
  set {
    name  = "configuration.backupStorageLocation.config.region"
    value = module.s3-bucket.s3_bucket_region
  }
  set {
    name  = "schedules.daily-aws-backups.schedule"
    value = var.aws_velero_schedule
  }
  set {
    name  = "snapshotsEnabled"
    value = var.aws_snapshots_enabled
  }
}
