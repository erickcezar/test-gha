variable "do_token" {
  description = "DigitalOcean token for terraform access"
  type        = string
  sensitive   = true
  default     = ""
}
