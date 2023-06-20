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

  runtime = "python3.10"
  timeout = 30

  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      # CALLBACK_URL = aws_apigatewayv2_stage.dev.invoke_url
      CALLBACK_URL = aws_lambda_function_url.bot-lambda-invocation-url.function_url
      TOKEN_VAR_NAME = aws_secretsmanager_secret.bot-token-secret.name
    }
  }

  depends_on = [data.archive_file.webhook-function-zip-file, ]
}