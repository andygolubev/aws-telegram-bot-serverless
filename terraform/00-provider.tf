terraform {
  backend "s3" {
    bucket         = "terraform-state-for-telegram-bot-serverless-us-east-1"
    key            = "terraform-state-for-telegram-bot-serverless-us-east-1/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-for-telegram-bot-serverless-locking-us-east-1"
    encrypt        = true
  }
  # end

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = " ~> 4.0"
    }
  }

}

provider "aws" {
  region = var.aws_region
}