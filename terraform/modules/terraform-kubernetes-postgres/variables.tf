variable "namespace" {
  type        = string
  description = "Namespace to deploy postgres"
  default     = "postgres"
}

variable "name" {
  type        = string
  description = "Name of the DBMS Database Management System"
  default     = "postgres"
}
