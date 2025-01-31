provider "aws" {
  region = "us-east-1"
}

# Configure Terraform for remote state
terraform {
  required_version = "1.10.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = ">= 0.55.0"
    }
  }
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}