resource "aws_apigatewayv2_api" "call-back-api" {
  name          = "callback-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "dev" {
  api_id = aws_apigatewayv2_api.call-back-api.id

  name        = "prod"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.call-back-api-gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_cloudwatch_log_group" "call-back-api-gw" {
  name = "/aws/api-gw/${aws_apigatewayv2_api.call-back-api.name}"

  retention_in_days = 14
}

resource "aws_apigatewayv2_integration" "api-gw-to-lambda" {
  api_id           = aws_apigatewayv2_api.call-back-api.id
  integration_type = "AWS_PROXY"

  description        = "Lambda bot integration"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.bot-lambda.invoke_arn
}

resource "aws_apigatewayv2_route" "post-callback-route" {
  api_id = aws_apigatewayv2_api.call-back-api.id

  route_key = "POST /"
  target    = "integrations/${aws_apigatewayv2_integration.api-gw-to-lambda.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.bot-lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.call-back-api.execution_arn}/*/*"
}
