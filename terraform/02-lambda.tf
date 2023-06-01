data "archive_file" "layer-zip-file" {
    type = "zip"

    source_dir  = "../lambda-bot/packages/"
    output_path = "/tmp/layer-package.zip"
}


resource "aws_lambda_layer_version" "lambda-layer-for-packages" {
    filename   = "/tmp/layer-package.zip"
    layer_name = "lambda-layer-for-packages"

    compatible_runtimes = ["python3.10"]
}

data "archive_file" "lambda-bot-zip-file" {
    type = "zip"

    source_dir = "../lambda-bot/bot-function/"
    output_path = "/tmp/lambda-bot.zip"
}

resource "aws_lambda_function" "bot-lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "/tmp/lambda-bot.zip"
  function_name = "bot-lambda"
  role          = aws_iam_role.lambdaRole.arn
  handler       = "bot.lambda_handler"
  layers        = [aws_lambda_layer_version.lambda-layer-for-packages.arn]

  source_code_hash = data.archive_file.lambda-bot-zip-file.output_base64sha256

  runtime = "python3.10"
  timeout = 30

  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      AWS_CLOUD_REGION = var.aws_region
    }
  }
}


data "archive_file" "webhook-function-zip-file" {
    type = "zip"

    source_dir = "../lambda-bot/webhook-function/"
    output_path = "/tmp/lambda-webhook.zip"
}

resource "aws_lambda_function" "webhook-lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "/tmp/lambda-webhook.zip"
  function_name = "webhook-lambda"
  role          = aws_iam_role.lambdaRole.arn
  handler       = "webhook.lambda_handler"
  layers        = [aws_lambda_layer_version.lambda-layer-for-packages.arn]

  source_code_hash = data.archive_file.webhook-function-zip-file.output_base64sha256

  runtime = "python3.10"
  timeout = 30

  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      CALLBACK_URL = aws_apigatewayv2_api.call-back-api.api_endpoint
    }
  }
}

