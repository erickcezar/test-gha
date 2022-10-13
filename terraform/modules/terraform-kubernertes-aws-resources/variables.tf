variable "AWS_ACCESS_KEY_ID" {
  type        = string
  sensitive   = true
  description = "AWS access key ID for accessing KMS"
  default     = ""
}

variable "AWS_SECRET_ACCESS_KEY" {
  type        = string
  sensitive   = true
  description = "AWS secret access key ID for accessing KMS"
  default     = ""
}

variable "AWS_REGION" {
  type        = string
  description = "AWS region for S3 and KMS key"
  default     = ""
}
