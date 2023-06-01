resource "aws_apigatewayv2_api" "call-back-api" {
  name          = "callback-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "dev" {
  api_id = aws_apigatewayv2_api.call-back-api.id

  name        = "prod"
  auto_deploy = true
}


resource "aws_apigatewayv2_integration" "api-gw-to-lambda" {
  api_id           = aws_apigatewayv2_api.call-back-api.id
  integration_type = "AWS_PROXY"

  description               = "Lambda bot integration"
  integration_method        = "POST"
  integration_uri           = aws_lambda_function.bot-lambda.invoke_arn
}

