# DynamoDB table for a bot statistics

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "aws-telegram-bot-statistics"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "UserID"
  attribute {
    name = "UserID"
    type = "N"
  }
  # attribute {
  #   name = "Recognitions"
  #   type = "N"
  # }

  tags = {
    Name      = "bot statistics dynamo table"
    CreatedBy = "Terraform"
    Region    = var.aws_region
  }
}
