
## CREATE a Layer for the bot-lambda ##

resource "null_resource" "pip-install" {
    provisioner "local-exec" {
      command = <<-EOF
      mkdir -p /tmp/packages/python/
      python3 -m venv /tmp/temp-venv
      source /tmp/temp-venv/bin/activate
      pip3 install -r ../lambda-bot/bot-function/requirements.txt -t /tmp/packages/python/
      EOF
    }
}

data "archive_file" "layer-zip-file" {
    type = "zip"

    source_dir  = "/tmp/packages/"
    output_path = "/tmp/layer-package.zip"

    depends_on = [ null_resource.pip-install,]
}

resource "aws_lambda_layer_version" "lambda-layer-for-packages" {
    filename   = "/tmp/layer-package.zip"
    layer_name = "lambda-layer-for-packages"

    compatible_runtimes = ["python3.10"]

    depends_on = [ data.archive_file.layer-zip-file, ]
}




## CREATE the bot-lambda ##

data "archive_file" "lambda-bot-zip-file" {
    type = "zip"

    source_dir = "../lambda-bot/bot-function/"
    output_path = "/tmp/lambda-bot.zip"
}

resource "aws_lambda_function" "bot-lambda" {
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

  depends_on = [ data.archive_file.lambda-bot-zip-file, ]
}



## CREATE the webhook-lambda ##

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

  depends_on = [ data.archive_file.webhook-function-zip-file, ]
}

