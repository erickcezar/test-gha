resource "kubernetes_namespace" "velero" {
  metadata {
    name = "velero"
    labels = {
      istio-injection      = "enabled"
      managed_by_terraform = "true"
    }
  }
}

module "velero" {
  source                        = "../modules/terraform-kubernetes-velero"
  velero_namespace              = kubernetes_namespace.velero.id
  AWS_ACCESS_KEY_ID             = var.AWS_ACCESS_KEY_ID
  AWS_SECRET_ACCESS_KEY         = var.AWS_SECRET_ACCESS_KEY
  aws_bucket_region             = "ca-central-1"
  aws_bucket_name               = "marketcircle-${local.region}-${local.environment}-velero-backups"
  aws_bucket_versioning_enabled = false
  aws_snapshots_enabled         = true        #Snapshots are stored in the Source cloud (DigitalOcean)
  aws_velero_schedule           = "0 7 * * *" #UTC Time

  do_token                                      = var.do_token
  do_spaces_key                                 = var.DO_SPACES_KEY
  do_spaces_secret                              = var.DO_SPACES_SECRET
  digitalocean_bucket_region                    = "nyc3"
  digitalocean_bucket_name                      = "marketcircle-${local.region}-${local.environment}-velero-backups"
  digitalocean_bucket_versioning_enabled        = false
  digitalocean_bucket_lifecycle_enabled         = true
  digitalocean_bucket_lifecycle_expiration_days = "60"
  digitalocean_snapshots_enabled                = false
  digitalocean_velero_schedule                  = "0 19 * * *" #UTC Time
}
