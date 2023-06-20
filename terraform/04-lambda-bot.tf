data "archive_file" "lambda-bot-zip-file" {
  type = "zip"

  source_dir  = "../lambda/bot-function/"
  output_path = "/tmp/lambda-bot.zip"
}

resource "aws_lambda_function" "bot-lambda" {
  filename      = "/tmp/lambda-bot.zip"
  function_name = "bot-lambda"
  role          = aws_iam_role.lambdaRole.arn
  handler       = "bot.lambda_handler"
  layers        = [aws_lambda_layer_version.lambda-layer-for-packages.arn]

  source_code_hash = data.archive_file.lambda-bot-zip-file.output_base64sha256

  runtime     = "python3.10"
  timeout     = 30
  memory_size = 256

  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      AWS_CLOUD_REGION = var.aws_region
      TOKEN_VAR_NAME   = aws_secretsmanager_secret.bot-token-secret.name
      LOGGING_LEVEL    = var.logging_level
    }
  }

  depends_on = [data.archive_file.lambda-bot-zip-file, ]
}

resource "aws_lambda_function_url" "bot-lambda-invocation-url" {
  function_name      = aws_lambda_function.bot-lambda.function_name
  authorization_type = "NONE"
}

resource "aws_cloudwatch_log_group" "lambda-log-bot" {
  name              = "/aws/lambda/${aws_lambda_function.bot-lambda.function_name}"
  retention_in_days = var.log-group-retention-period
}