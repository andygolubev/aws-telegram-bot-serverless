
data "aws_caller_identity" "current-account" {}

resource "aws_s3_bucket" "images-bucket" {
  bucket        = "telegram-bot-serverless1-${data.aws_caller_identity.current-account.account_id}"
  force_destroy = true

  tags = {
    Name      = "Images bucket"
    CreatedBy = "Terraform"
    Region    = var.aws_region
  }

}

resource "aws_s3_bucket_lifecycle_configuration" "images-bucket-name-lifecycle_configuration" {
  bucket = aws_s3_bucket.images-bucket.id

  rule {
    id     = "clear"
    status = "Enabled"

    expiration {
      days = 30
    }
  }
}

# resource "aws_s3_bucket_versioning" "bucket-versioning" {
#     bucket = aws_s3_bucket.terraform-state.id
#     versioning_configuration {
#     status = "Enabled"
#     }

# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "terraform-state-encryption" {
#     bucket = aws_s3_bucket.terraform-state.id
#     rule {
#       apply_server_side_encryption_by_default {
#         sse_algorithm = "AES256"
#       }
#     }

# }

# # DynamoDB table for LOCKs storage

# resource "aws_dynamodb_table" "terraform_locks" {
#     name = "terraform-state-locking-${var.aws_region}"
#     billing_mode = "PAY_PER_REQUEST"
#     hash_key = "LockID"
#     attribute {
#       name = "LockID"
#       type = "S"
#     }
#     tags = {
#         Name = "terraform state dynamo table"
#         CreatedBy= "Terraform"
#         Region = var.aws_region
#     }
# }


