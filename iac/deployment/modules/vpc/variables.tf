variable "bucket_name" {
  type        = string
  description = "AWS S3 bucket name"
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "provisioned_by" {
  type        = string
  description = "Provisioner automation/persona"
  default     = "Terraform"
}
