variable "bucket_name" {
  type        = string
  description = "AWS S3 bucket name"
}

variable "provisioned_by" {
  type        = string
  description = "Provisioner automation/persona"
  default     = "Terraform"
}
