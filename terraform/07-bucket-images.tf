
data "aws_caller_identity" "current-account" {}

resource "aws_s3_bucket" "images-bucket" {
  bucket        = "telegram-bot-serverless-${data.aws_caller_identity.current-account.account_id}"
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

