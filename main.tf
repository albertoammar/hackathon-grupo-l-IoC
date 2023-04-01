terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket  = "tf-state-171114599228"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    profile = "hackathon"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "hackathon"
}

# Para criar tfstate no s3
#data "aws_caller_identity" "current" {}
#
#locals {
#  account_id = data.aws_caller_identity.current.account_id
#}
#
#resource "aws_s3_bucket" "terraform_state" {
#  bucket = "tf-state-${local.account_id}"
#
#  tags = {
#    Description = "Terraform state bucket"
#    ManagedBy = "Terraform"
#  }
#}
#
#resource "aws_s3_bucket_versioning" "versioning_example" {
#  bucket = aws_s3_bucket.terraform_state.id
#  versioning_configuration {
#    status = "Enabled"
#  }
#}
#
#resource "aws_s3_bucket_public_access_block" "terraform_state" {
#  bucket = aws_s3_bucket.terraform_state.id
#
#  block_public_acls       = true
#  block_public_policy     = true
#  ignore_public_acls      = true
#  restrict_public_buckets = true
#}