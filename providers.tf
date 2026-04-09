# Update AWS provider to latest version
# No functional changes, just version bump

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40.0"
    }
  }
  required_version = ">= 1.7.0"
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "payments-platform"
      ManagedBy = "terraform"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}
