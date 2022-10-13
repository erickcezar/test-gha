locals {
  buckets = {
    # Buckets for Development Environment
    marketcircle-development-daylite-access-logs = {
      versioning     = true
      lifecycle_rule = []
      logging        = {}
    },

    marketcircle-development-daylite-attachments = {
      versioning = true
      lifecycle_rule = [
        {
          id                                     = "Delete previous versions"
          enabled                                = true
          prefix                                 = ""
          abort_incomplete_multipart_upload_days = 7
          noncurrent_version_expiration = {
            days = 30
          }
        },
        {
          id      = "Transition Storage Class To IA"
          enabled = true
          prefix  = ""

          transition = [
            {
              days          = 30
              storage_class = "STANDARD_IA"
            }
          ]
        }
      ]
      logging = {
        target_bucket = "marketcircle-development-daylite-access-logs"
        target_prefix = "attachments"
      }
    },

    marketcircle-development-daylite-email-migration = {
      versioning     = false
      lifecycle_rule = []
      logging = {
        target_bucket = "marketcircle-development-daylite-access-logs"
        target_prefix = "email-migration"
      }
    },


    marketcircle-development-daylite-exports = {
      versioning = false
      lifecycle_rule = [
        {
          id                                     = "Delete previous versions"
          enabled                                = true
          prefix                                 = ""
          abort_incomplete_multipart_upload_days = 7
          noncurrent_version_expiration = {
            days = 8
          }
        },
      ]
      logging = {
        target_bucket = "marketcircle-development-daylite-access-logs"
        target_prefix = "exports"
      }
    },

    marketcircle-development-daylite-externaldata = {
      versioning = true
      lifecycle_rule = [
        {
          id      = "Transition Storage Class To IT"
          enabled = true
          prefix  = ""

          transition = [
            {
              days          = 30
              storage_class = "INTELLIGENT_TIERING"
            }
          ]
        }
      ]
      logging = {
        target_bucket = "marketcircle-development-daylite-access-logs"
        target_prefix = "externaldata"
      }
    },

    marketcircle-development-daylite-pk-issue = {
      versioning = false
      lifecycle_rule = [
        {
          id                                     = "Delete previous versions"
          enabled                                = true
          prefix                                 = ""
          abort_incomplete_multipart_upload_days = 7
          noncurrent_version_expiration = {
            days = 90
          }
        },
      ]
      logging = {
        target_bucket = "marketcircle-development-daylite-access-logs"
        target_prefix = "pk-issue"
      }
    },
    
    marketcircle-development-daylite-backups = {
      versioning     = true
      lifecycle_rule = []
      logging = {
        target_bucket = "marketcircle-development-daylite-access-logs"
        target_prefix = "backups"
      }
    },

    # Buckets for Transient Environment
    marketcircle-transient-daylite-attachments = {
      versioning = true
      lifecycle_rule = [
        {
          id                                     = "Delete previous versions"
          enabled                                = true
          prefix                                 = ""
          abort_incomplete_multipart_upload_days = 7
          noncurrent_version_expiration = {
            days = 30
          }
        },
        {
          id      = "Transition Storage Class To IA"
          enabled = true
          prefix  = ""

          transition = [
            {
              days          = 30
              storage_class = "STANDARD_IA"
            }
          ]
        }
      ]
      logging = {}
    },

    marketcircle-transient-daylite-email-migration = {
      versioning     = false
      lifecycle_rule = []
      logging        = {}
    },

    marketcircle-transient-daylite-exports = {
      versioning = false
      lifecycle_rule = [
        {
          id                                     = "Delete previous versions"
          enabled                                = true
          prefix                                 = ""
          abort_incomplete_multipart_upload_days = 7
          noncurrent_version_expiration = {
            days = 8
          }
        },
      ]
      logging = {}
    },

    marketcircle-transient-daylite-externaldata = {
      versioning = true
      lifecycle_rule = [
        {
          id      = "Transition Storage Class To IT"
          enabled = true
          prefix  = ""

          transition = [
            {
              days          = 30
              storage_class = "INTELLIGENT_TIERING"
            }
          ]
        }
      ]
      logging = {}
    },

    marketcircle-transient-daylite-pk-issue = {
      versioning = false
      lifecycle_rule = [
        {
          id                                     = "Delete previous versions"
          enabled                                = true
          prefix                                 = ""
          abort_incomplete_multipart_upload_days = 7
          noncurrent_version_expiration = {
            days = 90
          }
        },
      ]
      logging = {}
    },

  }
}


module "s3-bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "2.11.1"

  for_each = local.buckets

  bucket        = each.key #local.bucket_name
  acl           = "private"
  force_destroy = false

  attach_policy = false
  #policy        = data.aws_iam_policy_document.bucket_policy.json

  attach_deny_insecure_transport_policy = false

  versioning = {
    enabled = each.value.versioning
  }


  logging = each.value.logging

  lifecycle_rule = each.value.lifecycle_rule

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
