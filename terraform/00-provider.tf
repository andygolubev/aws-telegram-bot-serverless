terraform {
  backend "s3" {
    #
    # Do not edit "us-east-1" value.
    # It will be replaced in the pipeline by the command: sed -i 's/us-east-1/${{ env.AWS_REGION }}/g' 00-provider.tf 
    #

    bucket         = "1terraform-state-for-telegram-bot-serverless-us-east-1"
    key            = "terraform-state-for-telegram-bot-serverless-us-east-1/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-for-telegram-bot-serverless-locking-us-east-1"
    encrypt        = true
  }

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