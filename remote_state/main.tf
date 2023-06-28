# data "aws_caller_identity" "current" {}

# locals {
#   account_id = data.aws_caller_identity.current.account_id
# }

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = ">=1.5.1"
  backend "s3" {
    bucket         = "<account_id>-terraform-states"
    key            = "state/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-locking"
  }
}



# ---------------------------------------
# CONFIGURE AWS CONNECTION
# ---------------------------------------
provider "aws" {
  region = "eu-west-2"
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

# ---------------------------------------
# CREATE S3 BUCKET FOR STATEFILE STORAGE
# ---------------------------------------



resource "aws_s3_bucket" "terraform_state" {
  #   bucket = "my-first-terraform-states"
  bucket = "${local.account_id}-terraform-states"

  #prevents accidental deletion of bucket
  lifecycle {
    prevent_destroy = true
  }

  #Enable versioning so the full revision history can be seen
  #   versioning {
  #     enabled = true
  #   }

  #Enable server-side encryption by default
  #   server_side_encryption_configuration {
  #     rule {
  #       apply_server_side_encryption_by_default {
  #         sse_algorithm = "AES256"
  #       }
  #     }
  #   }
  tags = {
    Name        = "My State Bucket"
    Environment = "Dev"
  }
}

# ---------------------------
# CREATE VERSIONING
# ---------------------------
resource "aws_s3_bucket_versioning" "bucket_versions" {
  bucket = aws_s3_bucket.terraform_state.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

# ---------------------------
# CREATE SERVER-SIDE ENCRYPTION
# ---------------------------
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encrypt" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}



# -----------------------------------------
# CREATE THE DYNAMODB TABLE for locking
# ----------------------------------------
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
