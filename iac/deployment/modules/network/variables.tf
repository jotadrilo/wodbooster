variable "provisioned_by" {
  type        = string
  description = "Provisioner automation/persona"
  default     = "Terraform"
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  type        = string
  description = "Subnet CIDR"
  default     = "10.0.0.0/16"
}

variable "name_prefix" {
  type        = string
  description = "Resources name prefix"
}

variable "assign_public_ip" {
  type        = bool
  description = "Specify true to indicate that instances launched into the subnet should be assigned a public IP address"
  default     = false
}
