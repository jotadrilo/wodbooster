terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  cloud {
    organization = "jotadrilo"

    workspaces {
      name = "wodbooster"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
