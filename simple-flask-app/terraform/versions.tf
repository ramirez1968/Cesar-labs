terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # State is local by default for this lab. If you want to collaborate
  # or avoid losing state, uncomment and configure an S3 backend:
  #
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "cesars-labs/simple-flask-app/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

provider "aws" {
  region = var.aws_region
}
