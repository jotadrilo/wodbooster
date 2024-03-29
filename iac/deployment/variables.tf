variable "provisioned_by" {
  type        = string
  description = "Provisioner automation/persona"
  default     = "Terraform"
}

variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-1"
}

variable "aws_account_id" {
  type        = string
  description = "Account ID"
  default     = "052585059257"
}

variable "ami_id" {
  type        = string
  description = "AMI ID"
  default     = "ami-0f9b93e48c5462ec0"
}

variable "wb_user_1" {
  type        = string
  description = "The username for the user 1"
  sensitive   = true
}

variable "wb_pass_1" {
  type        = string
  description = "The password for the user 1"
  sensitive   = true
}
