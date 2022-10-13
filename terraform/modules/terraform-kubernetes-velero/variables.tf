variable "velero_namespace" {
  type        = string
  description = "Namespace where velero should run"
  default     = "velero"
}

####
# S3 Bucket variables
###
variable "AWS_ACCESS_KEY_ID" {
  description = "AWS ID for velero access to API."
  type        = string
  sensitive   = true
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "AWS key for velero access to API."
  type        = string
  sensitive   = true
}

variable "aws_bucket_region" {
  type        = string
  description = "AWS S3 region to create buckets"
}

variable "aws_bucket_name" {
  type        = string
  description = "name of velero AWS bucket."
}

variable "aws_bucket_versioning_enabled" {
  type        = bool
  default     = false
  description = "Whether versioning is enabled or not in AWS S3 Bucket"
}

variable "aws_bucket_s3_force_ssl" {
  type        = bool
  default     = false
  description = "Controls if S3 bucket should have deny non-SSL transport policy attached	"
}

variable "aws_snapshots_enabled" {
  type        = bool
  default     = false
  description = "Variable to enable snapshot backup. IMPORTANT: the snapshot resides in the source provider and is not copied to AWS."
}

variable "aws_bucket_logging" {
  type        = map(any)
  default     = {}
  description = "Map containing target_bucket and target_prefix for logging access"
}

variable "aws_bucket_lifecycle_rule" {
  type        = any
  default     = []
  description = "List of maps containing configuration of object lifecycle management."
}

variable "aws_velero_schedule" {
  type        = string
  default     = "0 7 * * *"
  description = "Cron schedule for backups (ex: 0 7 * * *)"
}


####
# DigitalOcean Spaces Bucket variables
###
variable "do_token" {
  description = "DigitalOcean token for velero access to API. Used by snapshot feature"
  type        = string
  sensitive   = true
}
variable "do_spaces_key" {
  type        = string
  sensitive   = true
  description = "Digital Ocean Spaces key to access Spaces Buckets in Digital Ocean. Used for velero backups."
}

variable "do_spaces_secret" {
  type        = string
  sensitive   = true
  description = "Digital Ocean Spaces secret to access Spaces Buckets in Digital Ocean. Used for velero backups."
}

variable "digitalocean_bucket_region" {
  type        = string
  description = "Digital Ocean region to create backups in"
}

variable "digitalocean_velero_schedule" {
  type        = string
  default     = "0 19 * * *"
  description = "Cron schedule for backups (ex: 0 19 * * *)"
}

variable "digitalocean_snapshots_enabled" {
  type        = bool
  default     = false
  description = "Variable to enable snapshot backup"
}

variable "digitalocean_bucket_name" {
  type        = string
  description = "name of velero bucket in digitalocean."
}



variable "digitalocean_bucket_versioning_enabled" {
  type        = bool
  default     = false
  description = "Whether versioning is enabled or not in Digital Ocean Spaces Bucket"
}



variable "digitalocean_bucket_lifecycle_enabled" {
  type        = bool
  default     = false
  description = "Whether lifecycle is enabled or not in Digital Ocean Spaces Bucket"
}

variable "digitalocean_bucket_lifecycle_expiration_days" {
  type        = number
  default     = 365
  description = "Specifies a time period after which applicable objects expire. Require velero_lifecycle_enabled set to true"
}
