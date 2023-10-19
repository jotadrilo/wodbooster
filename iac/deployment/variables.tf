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
  default     = "ami-0af1b857ad706e162"
}
