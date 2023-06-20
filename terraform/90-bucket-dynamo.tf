### 
###        This section is used only for provision to the sandbox in us-east-1
###        For the prod environment this bucket and DynamoDB table are maid manually
###

# # S3 bucket (encrypted) for Terraform STATE file

# resource "aws_s3_bucket" "terraform-state" {
#     bucket = "devops-directive-tf-state-123-${var.aws_region}"
#     force_destroy = true

#     tags = {
#         Name = "terraform state s3"
#         CreatedBy= "Terraform"
#         Region = var.aws_region
#     }

# }

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


