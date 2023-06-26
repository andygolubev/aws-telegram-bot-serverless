data "archive_file" "webhook-function-zip-file" {
  type = "zip"

  source_dir  = "../lambda/webhook-function/"
  output_path = "/tmp/lambda-webhook.zip"
}

resource "aws_lambda_function" "webhook-lambda" {
  filename      = "/tmp/lambda-webhook.zip"
  function_name = "webhook-lambda"
  role          = aws_iam_role.lambdaRole.arn
  handler       = "webhook.lambda_handler"
  layers        = [aws_lambda_layer_version.lambda-layer-for-packages.arn]

  source_code_hash = data.archive_file.webhook-function-zip-file.output_base64sha256

  runtime     = "python3.10"
  timeout     = 30
  memory_size = 256

  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      CALLBACK_URL = aws_apigatewayv2_stage.prod.invoke_url
      #CALLBACK_URL     = aws_lambda_function_url.bot-lambda-invocation-url.function_url
      TOKEN_VAR_NAME   = aws_secretsmanager_secret.bot-token-secret.name
      AWS_CLOUD_REGION = var.aws_region
      LOGGING_LEVEL    = var.logging_level
    }
  }

  depends_on = [data.archive_file.webhook-function-zip-file]
}

data "aws_lambda_invocation" "webhook-lambda-invocation" {
  function_name = aws_lambda_function.webhook-lambda.function_name
  input         = "{}"

  depends_on = [aws_lambda_function.webhook-lambda, aws_cloudwatch_log_group.lambda-log-webhook]
}

resource "aws_cloudwatch_log_group" "lambda-log-webhook" {
  name              = "/aws/lambda/${aws_lambda_function.webhook-lambda.function_name}"
  retention_in_days = var.log_group_retention_period
}